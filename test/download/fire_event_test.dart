import 'package:flutter_civitai_box/services/download/download_magazine_item.dart';
import 'package:test/test.dart';

void main() {
  // =========================================================================
  // FireSummary
  // =========================================================================
  group('FireSummary', () {
    test('constructs with required fields', () {
      const summary = FireSummary(completed: 3, skipped: 1, failed: 1);
      expect(summary.completed, 3);
      expect(summary.skipped, 1);
      expect(summary.failed, 1);
    });

    test('has value equality', () {
      const a = FireSummary(completed: 5, skipped: 0, failed: 0);
      const b = FireSummary(completed: 5, skipped: 0, failed: 0);
      const c = FireSummary(completed: 4, skipped: 1, failed: 0);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('all zeros', () {
      const summary = FireSummary(completed: 0, skipped: 0, failed: 0);
      expect(summary.completed, 0);
      expect(summary.skipped, 0);
      expect(summary.failed, 0);
    });
  });

  // =========================================================================
  // FireEvent
  // =========================================================================
  final sampleItem = MagazineItem(
    id: 1,
    modelVersionId: 123456,
    modelId: 789,
    modelName: 'Test Model',
    modelJson: '{}',
    versionJson: '{}',
    status: MagazineItemStatus.pending,
    loadedAt: DateTime.parse('2026-06-07T10:00:00.000'),
  );

  group('FireEvent', () {
    test('roundStarted pattern matches as FireRoundStarted', () {
      final event = FireEvent.roundStarted(sampleItem);
      expect(event, isA<FireRoundStarted>());
    });

    test('roundStarted contains the item', () {
      final event = FireEvent.roundStarted(sampleItem);
      switch (event) {
        case FireRoundStarted(:final item):
          expect(item.modelVersionId, 123456);
          expect(item.modelName, 'Test Model');
        default:
          fail('Expected FireRoundStarted');
      }
    });

    test('retrying pattern matches as FireRetrying', () {
      final event = FireEvent.retrying(sampleItem, 2, 'Timeout');
      expect(event, isA<FireRetrying>());
    });

    test('retrying contains item, attempt, and reason', () {
      final event = FireEvent.retrying(sampleItem, 3, 'Connection lost');
      switch (event) {
        case FireRetrying(:final item, :final attempt, :final reason):
          expect(item.modelVersionId, 123456);
          expect(attempt, 3);
          expect(reason, 'Connection lost');
        default:
          fail('Expected FireRetrying');
      }
    });

    test('roundCompleted pattern matches as FireRoundCompleted', () {
      final event = FireEvent.roundCompleted(123456, 'Test Model');
      expect(event, isA<FireRoundCompleted>());
    });

    test('roundCompleted contains versionId and modelName', () {
      final event = FireEvent.roundCompleted(999, 'SDXL');
      switch (event) {
        case FireRoundCompleted(:final modelVersionId, :final modelName):
          expect(modelVersionId, 999);
          expect(modelName, 'SDXL');
        default:
          fail('Expected FireRoundCompleted');
      }
    });

    test('roundSkipped pattern matches as FireRoundSkipped', () {
      final event = FireEvent.roundSkipped(sampleItem);
      expect(event, isA<FireRoundSkipped>());
    });

    test('roundSkipped contains the item', () {
      final event = FireEvent.roundSkipped(sampleItem);
      switch (event) {
        case FireRoundSkipped(:final item):
          expect(item.modelVersionId, 123456);
        default:
          fail('Expected FireRoundSkipped');
      }
    });

    test('done pattern matches as FireDone', () {
      const summary = FireSummary(completed: 2, skipped: 0, failed: 1);
      final event = FireEvent.done(summary);
      expect(event, isA<FireDone>());
    });

    test('done contains summary', () {
      const summary = FireSummary(completed: 2, skipped: 0, failed: 1);
      final event = FireEvent.done(summary);
      switch (event) {
        case FireDone(:final summary):
          expect(summary.completed, 2);
          expect(summary.skipped, 0);
          expect(summary.failed, 1);
        default:
          fail('Expected FireDone');
      }
    });

    test('jammed pattern matches as FireJammed', () {
      final event = FireEvent.jammed(sampleItem);
      expect(event, isA<FireJammed>());
    });

    test('jammed contains the failed item', () {
      final event = FireEvent.jammed(sampleItem);
      switch (event) {
        case FireJammed(:final failedItem):
          expect(failedItem.modelVersionId, 123456);
          expect(failedItem.status, MagazineItemStatus.pending);
        default:
          fail('Expected FireJammed');
      }
    });

    test('FireEvent has value equality', () {
      final a = FireEvent.roundCompleted(1, 'A');
      final b = FireEvent.roundCompleted(1, 'A');
      final c = FireEvent.roundCompleted(2, 'A');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('different FireEvent subtypes are not equal', () {
      final started = FireEvent.roundStarted(sampleItem);
      final completed = FireEvent.roundCompleted(123456, 'Test Model');
      expect(started, isNot(equals(completed)));
    });
  });
}
