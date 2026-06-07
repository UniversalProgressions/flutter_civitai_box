import 'package:flutter_civitai_box/services/download/download_magazine_item.dart';
import 'package:test/test.dart';

void main() {
  // =========================================================================
  // MagazineItemStatus
  // =========================================================================
  group('MagazineItemStatus', () {
    test('has exactly four values', () {
      expect(MagazineItemStatus.values.length, 4);
      expect(
        MagazineItemStatus.values,
        containsAll([
          MagazineItemStatus.pending,
          MagazineItemStatus.firing,
          MagazineItemStatus.failed,
          MagazineItemStatus.skipped,
        ]),
      );
    });

    test('name strings match database values', () {
      expect(MagazineItemStatus.pending.name, 'pending');
      expect(MagazineItemStatus.firing.name, 'firing');
      expect(MagazineItemStatus.failed.name, 'failed');
      expect(MagazineItemStatus.skipped.name, 'skipped');
    });

    test('fromString parses valid status strings', () {
      expect(
        MagazineItemStatusX.fromString('pending'),
        MagazineItemStatus.pending,
      );
      expect(
        MagazineItemStatusX.fromString('firing'),
        MagazineItemStatus.firing,
      );
      expect(
        MagazineItemStatusX.fromString('failed'),
        MagazineItemStatus.failed,
      );
      expect(
        MagazineItemStatusX.fromString('skipped'),
        MagazineItemStatus.skipped,
      );
    });

    test('fromString throws on unknown status', () {
      expect(
        () => MagazineItemStatusX.fromString('bogus'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // =========================================================================
  // MagazineItem.fromRow
  // =========================================================================
  group('MagazineItem.fromRow', () {
    final validRow = <String, Object?>{
      'id': 1,
      'model_version_id': 123456,
      'model_id': 789,
      'model_name': 'Test Model',
      'version_name': 'v1.0',
      'base_model': 'SD 1.5',
      'model_type': 'Checkpoint',
      'file_count': 3,
      'total_size_kb': 7168000.0,
      'model_json': '{"id":789,"name":"Test Model"}',
      'version_json': '{"id":123456,"name":"v1.0"}',
      'status': 'pending',
      'retry_count': 0,
      'error_message': null,
      'loaded_at': '2026-06-07T10:00:00.000',
      'fired_at': null,
    };

    test('parses a valid row with all fields', () {
      final item = MagazineItem.fromRow(validRow);

      expect(item.id, 1);
      expect(item.modelVersionId, 123456);
      expect(item.modelId, 789);
      expect(item.modelName, 'Test Model');
      expect(item.versionName, 'v1.0');
      expect(item.baseModel, 'SD 1.5');
      expect(item.modelType, 'Checkpoint');
      expect(item.fileCount, 3);
      expect(item.totalSizeKb, 7168000.0);
      expect(item.modelJson, '{"id":789,"name":"Test Model"}');
      expect(item.versionJson, '{"id":123456,"name":"v1.0"}');
      expect(item.status, MagazineItemStatus.pending);
      expect(item.retryCount, 0);
      expect(item.errorMessage, isNull);
      expect(item.loadedAt, DateTime.parse('2026-06-07T10:00:00.000'));
      expect(item.firedAt, isNull);
    });

    test('parses nullable fields as null', () {
      final row = Map<String, Object?>.from(validRow)
        ..['version_name'] = null
        ..['base_model'] = null
        ..['model_type'] = null
        ..['error_message'] = null
        ..['fired_at'] = null;

      final item = MagazineItem.fromRow(row);

      expect(item.versionName, isNull);
      expect(item.baseModel, isNull);
      expect(item.modelType, isNull);
      expect(item.errorMessage, isNull);
      expect(item.firedAt, isNull);
    });

    test('parses fired_at when present', () {
      final row = Map<String, Object?>.from(validRow)
        ..['fired_at'] = '2026-06-07T12:00:00.000';

      final item = MagazineItem.fromRow(row);

      expect(item.firedAt, DateTime.parse('2026-06-07T12:00:00.000'));
    });

    test('parses failed status', () {
      final row = Map<String, Object?>.from(validRow)
        ..['status'] = 'failed'
        ..['retry_count'] = 3
        ..['error_message'] = 'Network timeout';

      final item = MagazineItem.fromRow(row);

      expect(item.status, MagazineItemStatus.failed);
      expect(item.retryCount, 3);
      expect(item.errorMessage, 'Network timeout');
    });

    test('parses skipped status', () {
      final row = Map<String, Object?>.from(validRow)..['status'] = 'skipped';

      final item = MagazineItem.fromRow(row);

      expect(item.status, MagazineItemStatus.skipped);
    });

    test('parses firing status', () {
      final row = Map<String, Object?>.from(validRow)..['status'] = 'firing';

      final item = MagazineItem.fromRow(row);

      expect(item.status, MagazineItemStatus.firing);
    });

    test('zero file_count and total_size_kb', () {
      final row = Map<String, Object?>.from(validRow)
        ..['file_count'] = 0
        ..['total_size_kb'] = 0.0;

      final item = MagazineItem.fromRow(row);

      expect(item.fileCount, 0);
      expect(item.totalSizeKb, 0.0);
    });

    test('throws when id is missing', () {
      final row = Map<String, Object?>.from(validRow)..remove('id');
      expect(() => MagazineItem.fromRow(row), throwsA(isA<ArgumentError>()));
    });

    test('throws when model_version_id is missing', () {
      final row = Map<String, Object?>.from(validRow)
        ..remove('model_version_id');
      expect(() => MagazineItem.fromRow(row), throwsA(isA<ArgumentError>()));
    });

    test('throws when model_name is missing', () {
      final row = Map<String, Object?>.from(validRow)..remove('model_name');
      expect(() => MagazineItem.fromRow(row), throwsA(isA<ArgumentError>()));
    });

    test('handles integer total_size_kb from SQLite (REAL stored as INT)', () {
      // SQLite may store REAL 0 as INTEGER 0
      final row = Map<String, Object?>.from(validRow)..['total_size_kb'] = 0;
      final item = MagazineItem.fromRow(row);
      expect(item.totalSizeKb, 0.0);
    });
  });

  // =========================================================================
  // MagazineItem.toRow
  // =========================================================================
  group('MagazineItem.toRow', () {
    final item = MagazineItem(
      id: 1,
      modelVersionId: 123456,
      modelId: 789,
      modelName: 'Test Model',
      versionName: 'v1.0',
      baseModel: 'SD 1.5',
      modelType: 'Checkpoint',
      fileCount: 3,
      totalSizeKb: 7168000.0,
      modelJson: '{"id":789,"name":"Test Model"}',
      versionJson: '{"id":123456,"name":"v1.0"}',
      status: MagazineItemStatus.pending,
      retryCount: 0,
      errorMessage: null,
      loadedAt: DateTime.parse('2026-06-07T10:00:00.000'),
      firedAt: null,
    );

    test('produces correct column map', () {
      final row = item.toRow();

      expect(row['id'], 1);
      expect(row['model_version_id'], 123456);
      expect(row['model_id'], 789);
      expect(row['model_name'], 'Test Model');
      expect(row['version_name'], 'v1.0');
      expect(row['base_model'], 'SD 1.5');
      expect(row['model_type'], 'Checkpoint');
      expect(row['file_count'], 3);
      expect(row['total_size_kb'], 7168000.0);
      expect(row['model_json'], '{"id":789,"name":"Test Model"}');
      expect(row['version_json'], '{"id":123456,"name":"v1.0"}');
      expect(row['status'], 'pending');
      expect(row['retry_count'], 0);
      expect(row['error_message'], isNull);
      expect(row['loaded_at'], '2026-06-07T10:00:00.000');
      expect(row['fired_at'], isNull);
    });

    test('round-trips with fromRow', () {
      final row = item.toRow();
      final restored = MagazineItem.fromRow(row);

      expect(restored.id, item.id);
      expect(restored.modelVersionId, item.modelVersionId);
      expect(restored.modelId, item.modelId);
      expect(restored.modelName, item.modelName);
      expect(restored.versionName, item.versionName);
      expect(restored.baseModel, item.baseModel);
      expect(restored.modelType, item.modelType);
      expect(restored.fileCount, item.fileCount);
      expect(restored.totalSizeKb, item.totalSizeKb);
      expect(restored.modelJson, item.modelJson);
      expect(restored.versionJson, item.versionJson);
      expect(restored.status, item.status);
      expect(restored.retryCount, item.retryCount);
      expect(restored.errorMessage, item.errorMessage);
      expect(restored.loadedAt, item.loadedAt);
      expect(restored.firedAt, item.firedAt);
    });

    test('round-trips with nullable fields set to null', () {
      final itemWithNulls = MagazineItem(
        id: 2,
        modelVersionId: 999,
        modelId: 888,
        modelName: 'Minimal',
        versionName: null,
        baseModel: null,
        modelType: null,
        fileCount: 0,
        totalSizeKb: 0,
        modelJson: '{}',
        versionJson: '{}',
        status: MagazineItemStatus.skipped,
        retryCount: 0,
        errorMessage: null,
        loadedAt: DateTime.now(),
        firedAt: null,
      );

      final row = itemWithNulls.toRow();
      final restored = MagazineItem.fromRow(row);

      expect(restored.versionName, isNull);
      expect(restored.baseModel, isNull);
      expect(restored.modelType, isNull);
      expect(restored.errorMessage, isNull);
      expect(restored.firedAt, isNull);
    });

    test('round-trips with failed status and fired_at', () {
      final failedItem = MagazineItem(
        id: 3,
        modelVersionId: 111,
        modelId: 222,
        modelName: 'Fail Model',
        versionName: 'v3',
        baseModel: 'SDXL 1.0',
        modelType: 'LoRA',
        fileCount: 1,
        totalSizeKb: 144000,
        modelJson: '{}',
        versionJson: '{}',
        status: MagazineItemStatus.failed,
        retryCount: 3,
        errorMessage: 'Connection timed out',
        loadedAt: DateTime.parse('2026-06-07T08:00:00.000'),
        firedAt: DateTime.parse('2026-06-07T09:00:00.000'),
      );

      final row = failedItem.toRow();
      final restored = MagazineItem.fromRow(row);

      expect(restored.status, MagazineItemStatus.failed);
      expect(restored.retryCount, 3);
      expect(restored.errorMessage, 'Connection timed out');
      expect(restored.firedAt, DateTime.parse('2026-06-07T09:00:00.000'));
    });
  });

  // =========================================================================
  // MagazineItem.copyWith
  // =========================================================================
  group('MagazineItem.copyWith', () {
    final base = MagazineItem(
      id: 1,
      modelVersionId: 123456,
      modelId: 789,
      modelName: 'Test Model',
      versionName: 'v1.0',
      baseModel: 'SD 1.5',
      modelType: 'Checkpoint',
      fileCount: 3,
      totalSizeKb: 7168000.0,
      modelJson: '{"id":789,"name":"Test Model"}',
      versionJson: '{"id":123456,"name":"v1.0"}',
      status: MagazineItemStatus.pending,
      retryCount: 0,
      errorMessage: null,
      loadedAt: DateTime.parse('2026-06-07T10:00:00.000'),
      firedAt: null,
    );

    test('returns same object when no changes', () {
      final copy = base.copyWith();
      expect(copy.id, base.id);
      expect(copy.status, base.status);
      expect(copy.retryCount, base.retryCount);
    });

    test('updates status', () {
      final copy = base.copyWith(status: MagazineItemStatus.firing);
      expect(copy.status, MagazineItemStatus.firing);
      expect(base.status, MagazineItemStatus.pending); // original unchanged
    });

    test('updates retryCount', () {
      final copy = base.copyWith(retryCount: 2);
      expect(copy.retryCount, 2);
    });

    test('updates errorMessage', () {
      final copy = base.copyWith(errorMessage: 'Oops');
      expect(copy.errorMessage, 'Oops');
    });

    test('updates firedAt', () {
      final now = DateTime.now();
      final copy = base.copyWith(firedAt: now);
      expect(copy.firedAt, now);
    });

    test('clears errorMessage with clearErrorMessage flag', () {
      final withError = base.copyWith(errorMessage: 'Old error');
      final cleared = withError.copyWith(clearErrorMessage: true);
      expect(cleared.errorMessage, isNull);
    });
  });
}
