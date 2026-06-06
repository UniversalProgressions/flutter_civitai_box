import 'package:flutter_civitai_box/services/download/download_task.dart';
import 'package:test/test.dart';

void main() {
  const now = '2026-06-02T00:00:00.000';

  DownloadTask makeTask({
    String id = 't1',
    String batchId = 'b1',
    String status = 'pending',
    double progress = 0,
    String fileType = 'model',
    double sizeKb = 1024,
  }) {
    return DownloadTask(
      id: id,
      batchId: batchId,
      modelId: 1,
      modelVersionId: 10,
      fileName: 'test.safetensors',
      fileSizeKb: sizeKb,
      downloadUrl: 'https://example.com/test.safetensors',
      targetPath: '/tmp/test.safetensors',
      fileType: DownloadFileType.values.firstWhere((t) => t.name == fileType),
      status: status.asStatus,
      progress: progress,
      createdAt: now,
      updatedAt: now,
    );
  }

  // =========================================================================
  // DownloadTask
  // =========================================================================
  group('DownloadTask', () {
    test('fromRow and toRow round-trip', () {
      final task = makeTask(status: 'downloading', progress: 0.5);
      final row = task.toRow();
      final restored = DownloadTask.fromRow(row);

      expect(restored.id, equals(task.id));
      expect(restored.batchId, equals(task.batchId));
      expect(restored.modelId, equals(task.modelId));
      expect(restored.modelVersionId, equals(task.modelVersionId));
      expect(restored.fileName, equals(task.fileName));
      expect(restored.fileSizeKb, equals(task.fileSizeKb));
      expect(restored.downloadUrl, equals(task.downloadUrl));
      expect(restored.targetPath, equals(task.targetPath));
      expect(restored.fileType, equals(task.fileType));
      expect(restored.status, equals(task.status));
      expect(restored.progress, equals(task.progress));
    });

    test('status string conversion', () {
      expect('pending'.asStatus, equals(DownloadTaskStatus.pending));
      expect('downloading'.asStatus, equals(DownloadTaskStatus.downloading));
      expect('completed'.asStatus, equals(DownloadTaskStatus.completed));
      expect('failed'.asStatus, equals(DownloadTaskStatus.failed));
      expect('cancelled'.asStatus, equals(DownloadTaskStatus.cancelled));
      expect('unknown'.asStatus, equals(DownloadTaskStatus.pending));
    });

    test('status enum to string', () {
      expect(DownloadTaskStatus.pending.name, equals('pending'));
      expect(DownloadTaskStatus.downloading.name, equals('downloading'));
      expect(DownloadTaskStatus.completed.name, equals('completed'));
    });

    test('sizeFormatted', () {
      expect(makeTask(sizeKb: 500).sizeFormatted, equals('500 KB'));
      expect(makeTask(sizeKb: 2048).sizeFormatted, equals('2 MB'));
      expect(makeTask(sizeKb: 2097152).sizeFormatted, equals('2.0 GB'));
    });
  });

  // =========================================================================
  // DownloadQueueState
  // =========================================================================
  group('DownloadQueueState', () {
    test('batches groups tasks by batchId', () {
      final tasks = [
        makeTask(id: '1', batchId: 'b1', status: 'completed'),
        makeTask(id: '2', batchId: 'b1', status: 'completed'),
        makeTask(id: '3', batchId: 'b2', status: 'pending'),
      ];
      final state = DownloadQueueState(
        tasks: tasks,
        totalBatches: 2,
        completedBatches: 1,
      );

      final batches = state.batches;
      expect(batches.length, equals(2));
      expect(batches['b1']!.length, equals(2));
      expect(batches['b2']!.length, equals(1));
    });

    test('activeBatches returns non-completed batches', () {
      final tasks = [
        makeTask(id: '1', batchId: 'b1', status: 'completed'),
        makeTask(id: '2', batchId: 'b1', status: 'completed'),
        makeTask(id: '3', batchId: 'b2', status: 'pending'),
        makeTask(id: '4', batchId: 'b3', status: 'failed'),
      ];
      final state = DownloadQueueState(
        tasks: tasks,
        totalBatches: 3,
        completedBatches: 1,
      );

      final active = state.activeBatches;
      expect(active.length, equals(2)); // b2 and b3
      expect(active.any((e) => e.key == 'b2'), isTrue);
      expect(active.any((e) => e.key == 'b3'), isTrue);
      expect(active.any((e) => e.key == 'b1'), isFalse);
    });

    test('completedBatchList returns only fully completed batches', () {
      final tasks = [
        makeTask(id: '1', batchId: 'b1', status: 'completed'),
        makeTask(id: '2', batchId: 'b1', status: 'completed'),
        makeTask(id: '3', batchId: 'b2', status: 'completed'),
        makeTask(id: '4', batchId: 'b2', status: 'failed'),
      ];
      final state = DownloadQueueState(
        tasks: tasks,
        totalBatches: 2,
        completedBatches: 1,
      );

      final completed = state.completedBatchList;
      expect(completed.length, equals(1)); // only b1
      expect(completed.first.key, equals('b1'));
    });
  });
}
