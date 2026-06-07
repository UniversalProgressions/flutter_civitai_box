import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_civitai_box/services/download/download_magazine_item.dart';
import 'package:flutter_civitai_box/ui/download/widgets/magazine_item_tile.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

MagazineItem _sampleItem({
  int id = 1,
  int modelVersionId = 123456,
  String modelName = 'Test Model',
  String? versionName = 'v2.0',
  String? baseModel = 'SD 1.5',
  String? modelType = 'Checkpoint',
  int fileCount = 3,
  double totalSizeKb = 7168000.0,
  MagazineItemStatus status = MagazineItemStatus.pending,
  int retryCount = 0,
  String? errorMessage,
}) {
  return MagazineItem(
    id: id,
    modelVersionId: modelVersionId,
    modelId: 789,
    modelName: modelName,
    versionName: versionName,
    baseModel: baseModel,
    modelType: modelType,
    fileCount: fileCount,
    totalSizeKb: totalSizeKb,
    modelJson: '{}',
    versionJson: '{}',
    status: status,
    retryCount: retryCount,
    errorMessage: errorMessage,
    loadedAt: DateTime.now(),
  );
}

void main() {
  group('MagazineItemTile', () {
    testWidgets('renders pending round with model info', (tester) async {
      final item = _sampleItem();
      await tester.pumpWidget(_wrap(MagazineItemTile(item: item)));
      expect(find.text('Test Model — v2.0'), findsOneWidget);
      expect(find.text('Checkpoint · 3 files · 6.8 GB'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    });

    testWidgets('renders firing round with spinner', (tester) async {
      final item = _sampleItem(status: MagazineItemStatus.firing);
      await tester.pumpWidget(_wrap(MagazineItemTile(item: item)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders failed round with error and action buttons', (
      tester,
    ) async {
      final item = _sampleItem(
        status: MagazineItemStatus.failed,
        retryCount: 3,
        errorMessage: 'Connection timed out',
      );
      await tester.pumpWidget(
        _wrap(MagazineItemTile(item: item, onSkip: () {}, onRetry: () {})),
      );
      expect(find.text('Connection timed out'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders skipped round', (tester) async {
      final item = _sampleItem(status: MagazineItemStatus.skipped);
      await tester.pumpWidget(_wrap(MagazineItemTile(item: item)));
      expect(find.text('Skipped'), findsOneWidget);
      expect(find.byIcon(Icons.skip_next), findsOneWidget);
    });

    testWidgets('calls onUnload when unload button pressed', (tester) async {
      final item = _sampleItem();
      var unloaded = false;
      await tester.pumpWidget(
        _wrap(MagazineItemTile(item: item, onUnload: () => unloaded = true)),
      );
      await tester.tap(find.byIcon(Icons.close));
      expect(unloaded, true);
    });
  });
}
