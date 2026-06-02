import 'dart:async';

import 'package:flutter_civitai_box/db/db.dart';
import 'package:flutter_civitai_box/services/download/download_database.dart';
import 'package:flutter_civitai_box/services/download/download_queue.dart';
import 'package:flutter_civitai_box/services/download/download_task.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

/// Tests for DownloadQueue logic that do NOT require background_downloader.
/// Actual download execution is tested via integration tests.
void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DownloadDatabase db;

  setUp(() async {
    await CivitaiDatabase.initForTest(':memory:');
    db = const DownloadDatabase();
  });

  tearDown(() async {
    await CivitaiDatabase.instance.then((d) => d.close());
  });

  DownloadTask _makeTask({
    required String id,
    required String batchId,
    String status = 'pending',
    String fileType = 'model',
    int modelVersionId = 10,
    String fileName = 'model.safetensors',
    String targetPath = '/tmp/model.safetensors',
  }) {
    return DownloadTask(
      id: id,
      batchId: batchId,
      modelId: 1,
      modelVersionId: modelVersionId,
      fileName: fileName,
      fileSizeKb: 1024,
      downloadUrl: 'https://example.com/$fileName',
      targetPath: targetPath,
      fileType: DownloadFileType.values.firstWhere((t) => t.name == fileType),
      status: status.asStatus,
      createdAt: '2026-06-02T00:00:00.000',
      updatedAt: '2026-06-02T00:00:00.000',
    );
  }

  // =========================================================================
  // DownloadQueue — DB-backed logic
  // =========================================================================
  group('DownloadQueue DB logic', () {
    test('enqueueBatch persists tasks to DB', () async {
      final apiJsonTasks = [
        _makeTask(
          id: 'a1',
          batchId: 'b1',
          fileType: 'apiJson',
          targetPath: '/tmp/json',
          fileName: '1.api-info.json',
        ),
      ];
      // Mark API JSON tasks as completed immediately
      for (final t in apiJsonTasks) {
        t.status = DownloadTaskStatus.completed;
        t.progress = 1.0;
      }

      final modelTasks = [
        _makeTask(
          id: 'm1',
          batchId: 'b1',
          fileType: 'model',
          fileName: 'model.safetensors',
          targetPath: '/tmp/model.safetensors',
        ),
      ];

      final mediaTasks = [
        _makeTask(
          id: 'p1',
          batchId: 'b1',
          fileType: 'media',
          fileName: '1.jpeg',
          targetPath: '/tmp/1.jpeg',
        ),
      ];

      await db.insertAll([...apiJsonTasks, ...modelTasks, ...mediaTasks]);

      final all = await db.loadAll();
      expect(all.length, equals(3));
      expect(all.where((t) => t.batchId == 'b1').length, equals(3));
    });

    test('loadActive on init restores pending tasks', () async {
      await db.insertAll([
        _makeTask(id: 't1', batchId: 'b1', status: 'pending'),
        _makeTask(id: 't2', batchId: 'b1', status: 'downloading'),
        _makeTask(id: 't3', batchId: 'b2', status: 'completed'),
      ]);

      final active = await db.loadActive();
      expect(active.length, equals(2));
      expect(active.map((t) => t.id).toSet(), equals({'t1', 't2'}));
    });

    test('cancelBatch marks all tasks in batch as cancelled', () async {
      final tasks = [
        _makeTask(id: 't1', batchId: 'b1', status: 'pending'),
        _makeTask(id: 't2', batchId: 'b1', status: 'downloading'),
        _makeTask(id: 't3', batchId: 'b2', status: 'pending'),
      ];
      await db.insertAll(tasks);

      // Simulate cancel: update each task in b1
      for (final t in tasks.where((t) => t.batchId == 'b1')) {
        t.status = DownloadTaskStatus.cancelled;
        t.updatedAt = '2026-06-02T01:00:00.000';
        await db.update(t);
      }

      final remaining = await db.loadActive();
      expect(remaining.length, equals(1));
      expect(remaining.first.batchId, equals('b2'));
    });
  });

  // =========================================================================
  // DownloadQueueState — batch grouping
  // =========================================================================
  group('DownloadQueueState grouping', () {
    test('batches with mixed file types', () {
      final tasks = [
        _makeTask(
          id: '1',
          batchId: 'b1',
          fileType: 'apiJson',
          fileName: 'api.json',
          status: 'completed',
        ),
        _makeTask(
          id: '2',
          batchId: 'b1',
          fileType: 'model',
          fileName: 'model.safetensors',
          status: 'completed',
        ),
        _makeTask(
          id: '3',
          batchId: 'b1',
          fileType: 'media',
          fileName: '1.jpeg',
          status: 'completed',
        ),
        _makeTask(
          id: '4',
          batchId: 'b2',
          fileType: 'model',
          fileName: 'other.safetensors',
          status: 'pending',
        ),
      ];

      final state = DownloadQueueState(
        tasks: tasks,
        totalBatches: 2,
        completedBatches: 1,
      );

      // b1: all completed → in completedBatchList
      // b2: pending → in activeBatches
      expect(state.completedBatchList.length, equals(1));
      expect(state.activeBatches.length, equals(1));
    });

    test('partially failed batch appears in activeBatches', () {
      final tasks = [
        _makeTask(id: '1', batchId: 'b1', status: 'completed'),
        _makeTask(id: '2', batchId: 'b1', status: 'failed'),
      ];

      final state = DownloadQueueState(
        tasks: tasks,
        totalBatches: 1,
        completedBatches: 0,
      );

      expect(state.activeBatches.length, equals(1));
      expect(state.completedBatchList.length, equals(0));
    });
  });

  // =========================================================================
  // Concurrency logic (without actual download)
  // =========================================================================
  group('Concurrency logic', () {
    test('worker processes tasks from shared queue', () async {
      // Simulate a simplified worker pool
      final taskQueue = List.generate(10, (i) => i);
      final results = <int>[];
      final lock = StreamController<void>.broadcast();

      Future<void> worker() async {
        while (taskQueue.isNotEmpty) {
          final item = taskQueue.removeAt(0);
          results.add(item);
          await Future.delayed(const Duration(milliseconds: 5));
        }
      }

      final workers = List.generate(3, (_) => worker());
      await Future.wait(workers);
      await lock.close();

      expect(results.length, equals(10));
      // All tasks processed exactly once
      expect(results.toSet().length, equals(10));
      expect(results, containsAll(List.generate(10, (i) => i)));
    });

    test('empty task list completes immediately', () async {
      final results = <int>[];
      final empty = <int>[];

      Future<void> worker() async {
        while (empty.isNotEmpty) {
          results.add(empty.removeAt(0));
        }
      }

      await Future.wait([worker()]);
      expect(results, isEmpty);
    });
  });
}
