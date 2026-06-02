import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart' as bg;
import 'package:path/path.dart' as p;

import '../model_refresh_bus.dart';
import 'download_database.dart';
import 'download_task.dart';

/// Central download queue — manages task lifecycle, persistence, and execution.
///
/// Usage:
/// ```dart
/// final queue = DownloadQueue.instance;
/// await queue.init();                              // restore tasks on startup
/// queue.stateStream.listen((s) => setState(...));   // bind to UI
/// await queue.enqueueBatch(tasks);                  // start downloading
/// ```
class DownloadQueue {
  DownloadQueue._();

  static final DownloadQueue _instance = DownloadQueue._();
  static DownloadQueue get instance => _instance;

  final DownloadDatabase _db = const DownloadDatabase();
  final StreamController<DownloadQueueState> _stateCtrl =
      StreamController<DownloadQueueState>.broadcast();

  Stream<DownloadQueueState> get stateStream => _stateCtrl.stream;

  /// The current queue state. Use this to get the initial state after subscribing.
  DownloadQueueState get currentState => _state;

  DownloadQueueState _state = const DownloadQueueState(
    tasks: [],
    totalBatches: 0,
    completedBatches: 0,
  );

  bool _initialized = false;
  bool _paused = false;
  final Set<String> _cancelledBatches = {};

  // ---------------------------------------------------------------------------
  // Init / Restore
  // ---------------------------------------------------------------------------

  /// Call once on app startup. Restores active tasks and loads history.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Load all tasks so completed history is visible after restart
    final all = await _db.loadAll();
    if (all.isEmpty) return;

    _state = _buildState(all);
    _stateCtrl.add(_state);

    // Resume only active (pending/downloading/failed) tasks
    for (final batch in _state.activeBatches) {
      _processBatch(batch.value);
    }
  }

  // ---------------------------------------------------------------------------
  // Enqueue
  // ---------------------------------------------------------------------------

  Future<void> enqueueBatch({
    required String batchId,
    required List<DownloadTask> apiJsonTasks,
    required List<DownloadTask> modelTasks,
    required List<DownloadTask> mediaTasks,
  }) async {
    final allTasks = <DownloadTask>[
      ...apiJsonTasks,
      ...modelTasks,
      ...mediaTasks,
    ];
    await _db.insertAll(allTasks);

    final tasks = await _db.loadAll();
    _state = _buildState(tasks);
    _stateCtrl.add(_state);

    _processBatch(allTasks);
  }

  // ---------------------------------------------------------------------------
  // Controls
  // ---------------------------------------------------------------------------

  void pause() {
    _paused = true;
    bg.FileDownloader().cancelAll();
  }

  void resume() {
    _paused = false;
  }

  Future<void> cancelBatch(String batchId) async {
    _cancelledBatches.add(batchId);
    final batchTasks = await _db.loadByBatch(batchId);
    for (final t in batchTasks) {
      if (t.backgroundTaskId != null) {
        try {
          await bg.FileDownloader().cancelTaskWithId(t.backgroundTaskId!);
        } catch (_) {}
      }
      t.status = DownloadTaskStatus.cancelled;
      t.updatedAt = DateTime.now().toIso8601String();
      await _db.update(t);
    }
    _refreshState();
  }

  Future<void> clearHistory() async {
    await _db.deleteCompleted();
    _refreshState();
  }

  /// Retry a failed or cancelled task by resetting it to pending and
  /// re-processing.
  Future<void> retryTask(String taskId) async {
    final tasks = await _db.loadAll();
    final task = tasks.where((t) => t.id == taskId).firstOrNull;
    if (task == null) return;

    task.status = DownloadTaskStatus.pending;
    task.progress = 0;
    task.errorMessage = null;
    task.backgroundTaskId = null;
    task.updatedAt = DateTime.now().toIso8601String();
    await _db.update(task);
    _cancelledBatches.remove(task.batchId);

    // Trigger re-processing for this task only
    _processBatch([task]);

    _refreshState();
  }

  // ---------------------------------------------------------------------------
  // Internal — batch processing
  // ---------------------------------------------------------------------------

  Future<void> _processBatch(List<DownloadTask> allTasks) async {
    final modelTasks = allTasks
        .where((t) => t.fileType == DownloadFileType.model)
        .toList();
    final mediaTasks = allTasks
        .where((t) => t.fileType == DownloadFileType.media)
        .toList();

    if (modelTasks.isNotEmpty) {
      await _downloadWithConcurrency(modelTasks, 2);
    }

    if (mediaTasks.isNotEmpty) {
      await _downloadWithConcurrency(mediaTasks, 4);
    }

    ModelRefreshBus.instance.notify();
  }

  Future<void> _downloadWithConcurrency(
    List<DownloadTask> tasks,
    int concurrency,
  ) async {
    final queue = List<DownloadTask>.from(tasks);

    Future<void> worker() async {
      while (queue.isNotEmpty) {
        if (_paused) {
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }

        final task = queue.removeAt(0);
        if (_cancelledBatches.contains(task.batchId)) continue;
        if (await _fileExists(task)) {
          task.status = DownloadTaskStatus.completed;
          task.progress = 1.0;
          task.updatedAt = DateTime.now().toIso8601String();
          await _db.update(task);
          _refreshState();
          continue;
        }

        await _downloadOne(task);
      }
    }

    final workers = List.generate(concurrency, (_) => worker());
    await Future.wait(workers);
  }

  Future<void> _downloadOne(DownloadTask task) async {
    task.status = DownloadTaskStatus.downloading;
    task.updatedAt = DateTime.now().toIso8601String();
    await _db.update(task);
    _refreshState();

    final dir = p.dirname(task.targetPath);
    final name = p.basename(task.targetPath);

    try {
      await Directory(dir).create(recursive: true);

      final bgTask = bg.DownloadTask(
        url: task.downloadUrl,
        filename: name,
        directory: dir,
        updates: bg.Updates.statusAndProgress,
        allowPause: true,
      );

      final result = await bg.FileDownloader().download(
        bgTask,
        onProgress: (progress) {
          task.progress = progress;
          task.updatedAt = DateTime.now().toIso8601String();
          _db.update(task);
          _refreshState();
        },
      );

      task.backgroundTaskId = result.task.taskId;

      if (result.status == bg.TaskStatus.complete) {
        task.status = DownloadTaskStatus.completed;
        task.progress = 1.0;
      } else {
        task.status = DownloadTaskStatus.failed;
        task.errorMessage =
            'Download failed: ${result.exception?.description ?? result.status.name}';
      }
    } catch (e) {
      task.status = DownloadTaskStatus.failed;
      task.errorMessage = e.toString();
    }

    task.updatedAt = DateTime.now().toIso8601String();
    await _db.update(task);
    _refreshState();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<bool> _fileExists(DownloadTask task) async {
    return File(task.targetPath).exists();
  }

  void _refreshState() async {
    final tasks = await _db.loadAll();
    _state = _buildState(tasks);
    _stateCtrl.add(_state);
  }

  DownloadQueueState _buildState(List<DownloadTask> tasks) {
    final batches = <String, List<DownloadTask>>{};
    for (final t in tasks) {
      batches.putIfAbsent(t.batchId, () => []).add(t);
    }
    return DownloadQueueState(
      tasks: tasks,
      totalBatches: batches.length,
      completedBatches: batches.values
          .where(
            (list) =>
                list.every((t) => t.status == DownloadTaskStatus.completed),
          )
          .length,
    );
  }

  void dispose() {
    _stateCtrl.close();
  }
}
