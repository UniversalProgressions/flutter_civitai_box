import 'package:flutter_civitai_box/services/download/download_magazine_item.dart';
import 'package:test/test.dart';

void main() {
  // =========================================================================
  // LoadErrorType
  // =========================================================================
  group('LoadErrorType', () {
    test('has all expected variants', () {
      expect(LoadErrorType.values.length, 5);
      expect(
        LoadErrorType.values,
        containsAll([
          LoadErrorType.invalidId,
          LoadErrorType.networkError,
          LoadErrorType.apiError,
          LoadErrorType.validationError,
          LoadErrorType.alreadyInMagazine,
        ]),
      );
    });
  });

  // =========================================================================
  // LoadError
  // =========================================================================
  group('LoadError', () {
    test('constructs with required fields', () {
      const error = LoadError(
        type: LoadErrorType.invalidId,
        message: 'Model version ID must be a positive integer',
      );
      expect(error.type, LoadErrorType.invalidId);
      expect(error.message, 'Model version ID must be a positive integer');
      expect(error.detail, isNull);
    });

    test('constructs with detail', () {
      const error = LoadError(
        type: LoadErrorType.validationError,
        message: 'Invalid API response',
        detail: 'Missing required field: modelId',
      );
      expect(error.type, LoadErrorType.validationError);
      expect(error.message, 'Invalid API response');
      expect(error.detail, 'Missing required field: modelId');
    });

    test('has value equality', () {
      const a = LoadError(type: LoadErrorType.apiError, message: 'A');
      const b = LoadError(type: LoadErrorType.apiError, message: 'A');
      const c = LoadError(type: LoadErrorType.apiError, message: 'B');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));

      // Different type
      const d = LoadError(type: LoadErrorType.networkError, message: 'A');
      expect(a, isNot(equals(d)));
    });

    test('toString includes type and message', () {
      const error = LoadError(
        type: LoadErrorType.alreadyInMagazine,
        message: 'Version 123 is already in the magazine',
      );
      final str = error.toString();
      expect(str, contains('alreadyInMagazine'));
      expect(str, contains('Version 123 is already in the magazine'));
    });
  });

  // =========================================================================
  // LoadResult
  // =========================================================================
  group('LoadResult', () {
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

    test('LoadResult.ok pattern matches as LoadOk', () {
      final result = LoadResult.ok(sampleItem);
      expect(result, isA<LoadOk>());
      expect(result, isNot(isA<LoadError_>()));
    });

    test('LoadResult.ok contains the item', () {
      final result = LoadResult.ok(sampleItem);
      switch (result) {
        case LoadOk(:final item):
          expect(item.id, 1);
          expect(item.modelVersionId, 123456);
          expect(item.modelName, 'Test Model');
        case LoadError_():
          fail('Expected LoadOk, got LoadError_');
      }
    });

    test('LoadResult.error pattern matches as LoadError_', () {
      const loadError = LoadError(
        type: LoadErrorType.invalidId,
        message: 'Bad ID',
      );
      final result = LoadResult.error(loadError);
      expect(result, isA<LoadError_>());
      expect(result, isNot(isA<LoadOk>()));
    });

    test('LoadResult.error contains the error', () {
      const loadError = LoadError(
        type: LoadErrorType.networkError,
        message: 'Connection refused',
        detail: 'SocketException',
      );
      final result = LoadResult.error(loadError);
      switch (result) {
        case LoadOk():
          fail('Expected LoadError_, got LoadOk');
        case LoadError_(:final error):
          expect(error.type, LoadErrorType.networkError);
          expect(error.message, 'Connection refused');
          expect(error.detail, 'SocketException');
      }
    });

    test('LoadResult.ok has value equality', () {
      final a = LoadResult.ok(sampleItem);
      final b = LoadResult.ok(sampleItem);
      expect(a, equals(b));
    });

    test('LoadResult.error has value equality', () {
      const err = LoadError(type: LoadErrorType.apiError, message: 'E');
      final a = LoadResult.error(err);
      final b = LoadResult.error(err);
      expect(a, equals(b));
    });

    test('LoadResult.ok and LoadResult.error are not equal', () {
      final ok = LoadResult.ok(sampleItem);
      final err = LoadResult.error(
        const LoadError(type: LoadErrorType.apiError, message: 'E'),
      );
      expect(ok, isNot(equals(err)));
    });
  });
}
