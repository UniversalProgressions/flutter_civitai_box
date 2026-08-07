import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart' as bg;
import 'package:path/path.dart' as p;

import '../logger.dart';
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

  /// Target paths currently being downloaded, so two batches never write the
  /// same file concurrently.
  final Set<String> _activePaths = {};

  /// Whether the whole queue is paused.
  bool get isPaused => _paused;

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

    // One-time cleanup of historical duplicate batches (same version spread
    // across several batches — a known cause of duplicate downloads).
    await _deduplicateActiveBatches();

    final refreshed = await _db.loadAll();
    _state = _buildState(refreshed);
    _stateCtrl.add(_state);

    // Resume only active (pending/downloading/failed) tasks
    for (final batch in _state.activeBatches) {
      _processBatch(batch.value);
    }
  }

  /// One-time cleanup on startup: if a model version has active tasks spread
  /// across multiple batches, keep the most recent batch and delete the rest.
  Future<void> _deduplicateActiveBatches() async {
    final all = await _db.loadAll();
    final active = all
        .where(
          (t) =>
              t.status != DownloadTaskStatus.completed &&
              t.status != DownloadTaskStatus.cancelled,
        )
        .toList();

    // versionId -> (batchId -> latest createdAt)
    final byVersion = <int, Map<String, String>>{};
    for (final t in active) {
      final batches = byVersion.putIfAbsent(t.modelVersionId, () => {});
      final existing = batches[t.batchId];
      if (existing == null || t.createdAt.compareTo(existing) > 0) {
        batches[t.batchId] = t.createdAt;
      }
    }

    for (final entry in byVersion.entries) {
      if (entry.value.length <= 1) continue;
      final sorted = entry.value.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value)); // ascending
      final keep = sorted.last.key;
      for (final b in sorted) {
        if (b.key == keep) continue;
        logger.info(
          'Dedup: deleting duplicate batch ${b.key} for version ${entry.key}',
        );
        await _db.deleteBatch(b.key);
      }
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

  /// Pause the queue: stop pulling new tasks and cancel in-flight background
  /// downloads. In-flight tasks are reset to `pending` so they can resume.
  void pause() {
    _paused = true;
    bg.FileDownloader().cancelAll();
  }

  /// Resume the queue: reprocess every `pending` task (both never-started and
  /// cancelled-while-paused).
  Future<void> resume() async {
    _paused = false;
    final tasks = await _db.loadAll();
    final pending = tasks
        .where((t) => t.status == DownloadTaskStatus.pending)
        .toList();
    final byBatch = <String, List<DownloadTask>>{};
    for (final t in pending) {
      byBatch.putIfAbsent(t.batchId, () => []).add(t);
    }
    for (final batch in byBatch.values) {
      _processBatch(batch);
    }
  }

  Future<void> cancelBatch(String batchId) async {
    _cancelledBatches.add(batchId);
    final batchTasks = await _db.loadByBatch(batchId);
    for (final t in batchTasks) {
      final wasCompleted = t.status == DownloadTaskStatus.completed;
      if (t.backgroundTaskId != null) {
        try {
          await bg.FileDownloader().cancelTaskWithId(t.backgroundTaskId!);
        } catch (_) {}
      }
      t.status = DownloadTaskStatus.cancelled;
      t.updatedAt = DateTime.now().toIso8601String();
      await _db.update(t);
      // Deleting an unfinished task also removes its partial download files.
      if (!wasCompleted) {
        await _cleanupTaskFiles(t);
      }
    }
    _refreshState();
  }

  /// Best-effort removal of leftover partial download artifacts for a task
  /// that did not finish. `background_downloader` already deletes its own temp
  /// file on cancel; this covers any partial file left at the final path (or a
  /// `.part` variant).
  Future<void> _cleanupTaskFiles(DownloadTask task) async {
    for (final path in [task.targetPath, '${task.targetPath}.part']) {
      try {
        final f = File(path);
        if (await f.exists()) await f.delete();
      } catch (_) {
        // Best-effort cleanup; ignore failures.
      }
    }
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

  /// Tasks for a model version that are still active
  /// (pending / downloading / failed) — i.e. not yet finished.
  ///
  /// Used to detect and reuse an existing batch instead of enqueueing a
  /// duplicate one.
  Future<List<DownloadTask>> nonCompletedTasksForVersion(
    int modelVersionId,
  ) async {
    final tasks = await _db.loadAll();
    return tasks
        .where((t) => t.modelVersionId == modelVersionId)
        .where(
          (t) =>
              t.status != DownloadTaskStatus.completed &&
              t.status != DownloadTaskStatus.cancelled,
        )
        .toList();
  }

  /// All task rows for a model version (any status).
  Future<List<DownloadTask>> tasksForVersion(int modelVersionId) async {
    final tasks = await _db.loadAll();
    return tasks.where((t) => t.modelVersionId == modelVersionId).toList();
  }

  /// Reset every task in a batch back to `pending` and re-process the whole
  /// batch. Completed files are skipped again by the file-existence check.
  ///
  /// This is the duplicate-safe alternative to enqueueing a brand-new batch:
  /// it reuses the existing rows instead of creating new ones.
  Future<void> retryBatch(String batchId) async {
    final tasks = await _db.loadByBatch(batchId);
    for (final t in tasks) {
      t.status = DownloadTaskStatus.pending;
      t.progress = 0;
      t.errorMessage = null;
      t.backgroundTaskId = null;
      t.updatedAt = DateTime.now().toIso8601String();
      await _db.update(t);
    }
    _cancelledBatches.remove(batchId);

    _processBatch(tasks);
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
        if (_paused) break; // stop pulling new tasks while paused

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
    // Wait if another batch is already downloading this exact file path, so
    // two batches never write the same file concurrently.
    while (_activePaths.contains(task.targetPath)) {
      if (_cancelledBatches.contains(task.batchId)) return;
      await Future.delayed(const Duration(milliseconds: 300));
    }
    // Another batch may have finished the file while we waited.
    if (await _fileExists(task)) {
      task.status = DownloadTaskStatus.completed;
      task.progress = 1.0;
      task.updatedAt = DateTime.now().toIso8601String();
      await _db.update(task);
      _refreshState();
      return;
    }
    _activePaths.add(task.targetPath);
    try {
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
        } else if (result.status == bg.TaskStatus.canceled) {
          // Cancelled: if paused, reset to pending so it resumes later;
          // otherwise keep the cancelled status set by cancelBatch().
          if (_paused) {
            task.status = DownloadTaskStatus.pending;
            task.progress = 0;
          } else {
            task.status = DownloadTaskStatus.cancelled;
          }
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
    } finally {
      _activePaths.remove(task.targetPath);
    }
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
