import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_civitai_box/services/download/download_task.dart';
import 'package:flutter_civitai_box/ui/download/widgets/download_batch_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

DownloadTask _task({
  String id = '1',
  String batchId = 'b1',
  int modelId = 789,
  int modelVersionId = 123,
  String? modelName = 'Test Model',
  String? versionName = 'v1.0',
  DownloadTaskStatus status = DownloadTaskStatus.pending,
}) {
  return DownloadTask(
    id: id,
    batchId: batchId,
    modelId: modelId,
    modelVersionId: modelVersionId,
    modelName: modelName,
    versionName: versionName,
    fileName: 'model.safetensors',
    fileSizeKb: 1024,
    downloadUrl: 'https://example.com/model',
    targetPath: '/tmp/model.safetensors',
    fileType: DownloadFileType.model,
    status: status,
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
  );
}

void main() {
  group('DownloadBatchCard', () {
    testWidgets('shows model name and version when present', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DownloadBatchCard(
            batchId: 'b1',
            tasks: [_task(modelName: 'DreamShaper', versionName: 'v8')],
          ),
        ),
      );
      expect(find.text('DreamShaper - v8'), findsOneWidget);
    });

    testWidgets('falls back to numeric IDs when names missing', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DownloadBatchCard(
            batchId: 'b1',
            tasks: [_task(modelName: null, versionName: null)],
          ),
        ),
      );
      expect(find.text('789 / v123'), findsOneWidget);
    });

    testWidgets('shows cancel button for active batch', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DownloadBatchCard(
            batchId: 'b1',
            tasks: [_task(status: DownloadTaskStatus.downloading)],
          ),
        ),
      );
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('no cancel button for completed batch', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DownloadBatchCard(
            batchId: 'b1',
            tasks: [_task(status: DownloadTaskStatus.completed)],
          ),
        ),
      );
      expect(find.byIcon(Icons.cancel), findsNothing);
    });
  });
}
