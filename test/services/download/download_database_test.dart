import 'package:flutter_civitai_box/db/db.dart';
import 'package:flutter_civitai_box/services/download/download_database.dart';
import 'package:flutter_civitai_box/services/download/download_task.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

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
    String id = 'task-1',
    String batchId = 'batch-1',
    String status = 'pending',
    double progress = 0,
    String fileType = 'model',
    int modelVersionId = 10,
    String fileName = 'model.safetensors',
  }) {
    return DownloadTask(
      id: id,
      batchId: batchId,
      modelId: 1,
      modelVersionId: modelVersionId,
      fileName: fileName,
      fileSizeKb: 1024,
      downloadUrl: 'https://example.com/$fileName',
      targetPath: '/tmp/$fileName',
      fileType: DownloadFileType.values.firstWhere((t) => t.name == fileType),
      status: status.asStatus,
      progress: progress,
      createdAt: '2026-06-02T00:00:00.000',
      updatedAt: '2026-06-02T00:00:00.000',
    );
  }

  // =========================================================================
  // DownloadDatabase
  // =========================================================================
  group('DownloadDatabase', () {
    test('insert and load single task', () async {
      final task = _makeTask();
      await db.insert(task);

      final all = await db.loadAll();
      expect(all.length, equals(1));
      expect(all.first.id, equals('task-1'));
      expect(all.first.status, equals(DownloadTaskStatus.pending));
    });

    test('insertAll multiple tasks', () async {
      final tasks = [
        _makeTask(id: 't1', batchId: 'b1'),
        _makeTask(id: 't2', batchId: 'b1'),
        _makeTask(id: 't3', batchId: 'b2'),
      ];
      await db.insertAll(tasks);

      final all = await db.loadAll();
      expect(all.length, equals(3));
    });

    test('update changes status and progress', () async {
      final task = _makeTask();
      await db.insert(task);

      task.status = DownloadTaskStatus.downloading;
      task.progress = 0.5;
      await db.update(task);

      final reloaded = (await db.loadAll()).first;
      expect(reloaded.status, equals(DownloadTaskStatus.downloading));
      expect(reloaded.progress, equals(0.5));
    });

    test('loadActive returns only non-terminal tasks', () async {
      await db.insertAll([
        _makeTask(id: 't1', status: 'pending'),
        _makeTask(id: 't2', status: 'downloading'),
        _makeTask(id: 't3', status: 'completed'),
        _makeTask(id: 't4', status: 'failed'),
        _makeTask(id: 't5', status: 'cancelled'),
      ]);

      final active = await db.loadActive();
      expect(active.length, equals(3)); // pending, downloading, failed
      expect(active.any((t) => t.id == 't1'), isTrue);
      expect(active.any((t) => t.id == 't2'), isTrue);
      expect(active.any((t) => t.id == 't4'), isTrue);
      expect(active.any((t) => t.id == 't3'), isFalse);
      expect(active.any((t) => t.id == 't5'), isFalse);
    });

    test('loadByBatch filters by batchId', () async {
      await db.insertAll([
        _makeTask(id: 't1', batchId: 'b1'),
        _makeTask(id: 't2', batchId: 'b1'),
        _makeTask(id: 't3', batchId: 'b2'),
      ]);

      final b1 = await db.loadByBatch('b1');
      expect(b1.length, equals(2));
      expect(b1.every((t) => t.batchId == 'b1'), isTrue);
    });

    test('hasActiveBatch detects active tasks', () async {
      await db.insert(_makeTask(modelVersionId: 99, status: 'pending'));
      expect(await db.hasActiveBatch(99), isTrue);

      await db.insert(
        _makeTask(id: 't2', modelVersionId: 100, status: 'completed'),
      );
      expect(await db.hasActiveBatch(100), isFalse);
    });

    test('deleteBatch removes specific batch', () async {
      await db.insertAll([
        _makeTask(id: 't1', batchId: 'b1'),
        _makeTask(id: 't2', batchId: 'b2'),
      ]);

      await db.deleteBatch('b1');

      final all = await db.loadAll();
      expect(all.length, equals(1));
      expect(all.first.batchId, equals('b2'));
    });

    test('deleteCompleted clears history', () async {
      await db.insertAll([
        _makeTask(id: 't1', status: 'completed'),
        _makeTask(id: 't2', status: 'cancelled'),
        _makeTask(id: 't3', status: 'pending'),
      ]);

      await db.deleteCompleted();

      final all = await db.loadAll();
      expect(all.length, equals(1));
      expect(all.first.id, equals('t3'));
    });
  });
}
