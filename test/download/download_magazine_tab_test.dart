import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_civitai_box/services/download/download_magazine_item.dart';
import 'package:flutter_civitai_box/ui/download/download_magazine_tab.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

MagazineItem _sample({
  int modelVersionId = 100,
  String modelName = 'Test Model',
  String versionName = 'v1.0',
  MagazineItemStatus status = MagazineItemStatus.pending,
  int retryCount = 0,
  String? errorMessage,
}) {
  return MagazineItem(
    id: modelVersionId,
    modelVersionId: modelVersionId,
    modelId: 789,
    modelName: modelName,
    versionName: versionName,
    baseModel: 'SD 1.5',
    modelType: 'Checkpoint',
    fileCount: 3,
    totalSizeKb: 7168000.0,
    modelJson: '{}',
    versionJson: '{}',
    status: status,
    retryCount: retryCount,
    errorMessage: errorMessage,
    loadedAt: DateTime.now(),
  );
}

void main() {
  group('DownloadMagazineTab', () {
    testWidgets('Load button disabled when input empty', (tester) async {
      await tester.pumpWidget(_wrap(const DownloadMagazineTab()));
      final loadBtn = find.widgetWithText(ElevatedButton, 'Load');
      final btn = tester.widget<ElevatedButton>(loadBtn);
      expect(btn.onPressed, isNull);
    });

    testWidgets('Fire button disabled when magazine empty', (tester) async {
      await tester.pumpWidget(_wrap(const DownloadMagazineTab()));
      final fireBtn = find.widgetWithText(ElevatedButton, 'Fire');
      final btn = tester.widget<ElevatedButton>(fireBtn);
      expect(btn.onPressed, isNull);
    });

    testWidgets('Fire button enabled when pending rounds exist', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(DownloadMagazineTab(initialRounds: [_sample()])),
      );
      final fireBtn = find.widgetWithText(ElevatedButton, 'Fire');
      final btn = tester.widget<ElevatedButton>(fireBtn);
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('renders pending rounds in list', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DownloadMagazineTab(
            initialRounds: [
              _sample(modelVersionId: 100, modelName: 'Model A'),
              _sample(modelVersionId: 200, modelName: 'Model B'),
            ],
          ),
        ),
      );
      expect(find.text('Model A'), findsOneWidget);
      expect(find.text('Model B'), findsOneWidget);
    });

    testWidgets('shows failed round with skip/retry buttons', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DownloadMagazineTab(
            initialRounds: [
              _sample(
                modelVersionId: 100,
                modelName: 'Failed Model',
                status: MagazineItemStatus.failed,
                retryCount: 3,
                errorMessage: 'Network timeout',
              ),
            ],
          ),
        ),
      );
      expect(find.text('Failed Model'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('Fire button disabled when jammed round exists', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          DownloadMagazineTab(
            initialRounds: [
              _sample(status: MagazineItemStatus.failed, retryCount: 3),
              _sample(modelVersionId: 200),
            ],
          ),
        ),
      );
      final fireBtn = find.widgetWithText(ElevatedButton, 'Fire');
      final btn = tester.widget<ElevatedButton>(fireBtn);
      expect(btn.onPressed, isNull);
    });
  });
}
