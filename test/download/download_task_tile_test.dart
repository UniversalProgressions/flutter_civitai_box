import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_civitai_box/services/download/download_task.dart';
import 'package:flutter_civitai_box/ui/download/widgets/download_task_tile.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

DownloadTask _task({
  String fileName = 'model.safetensors',
  double fileSizeKb = 1024,
  double progress = 0,
  DownloadTaskStatus status = DownloadTaskStatus.pending,
}) {
  return DownloadTask(
    id: 't1',
    batchId: 'b1',
    modelId: 789,
    modelVersionId: 123,
    modelName: 'Test Model',
    versionName: 'v1.0',
    fileName: fileName,
    fileSizeKb: fileSizeKb,
    downloadUrl: 'https://example.com/model',
    targetPath: '/tmp/$fileName',
    fileType: DownloadFileType.model,
    status: status,
    progress: progress,
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
  );
}

void main() {
  group('DownloadTaskTile', () {
    testWidgets('highlights the file currently being downloaded', (
      tester,
    ) async {
      final task = _task(status: DownloadTaskStatus.downloading, progress: 0.5);
      await tester.pumpWidget(_wrap(DownloadTaskTile(task: task)));
      final text = tester.widget<Text>(find.text('model.safetensors'));
      expect(text.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('does not highlight a pending file', (tester) async {
      final task = _task(status: DownloadTaskStatus.pending);
      await tester.pumpWidget(_wrap(DownloadTaskTile(task: task)));
      final text = tester.widget<Text>(find.text('model.safetensors'));
      expect(text.style?.fontWeight, isNot(FontWeight.w600));
    });

    testWidgets('shows percent and size while downloading', (tester) async {
      final task = _task(
        status: DownloadTaskStatus.downloading,
        progress: 0.5,
        fileSizeKb: 1024,
      );
      await tester.pumpWidget(_wrap(DownloadTaskTile(task: task)));
      // 50% and 1 MB (fresh build has no speed snapshot yet).
      expect(find.textContaining('50%'), findsOneWidget);
      expect(find.textContaining('1 MB'), findsOneWidget);
    });
  });
}
