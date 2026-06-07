import 'package:flutter_civitai_box/db/database.dart';
import 'package:flutter_civitai_box/services/download/download_magazine_item.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

// Will be imported once created:
// import 'package:flutter_civitai_box/services/download/download_magazine_database.dart';

void main() {
  // Use FFI for in-memory SQLite testing.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  const testDbPath = ':memory:';

  setUp(() async {
    await CivitaiDatabase.initForTest(testDbPath);
  });

  tearDown(() async {
    await CivitaiDatabase.instance.then((db) => db.close());
  });

  /// Helper to create a sample item for tests.
  MagazineItem sampleItem({
    int id = 1,
    int modelVersionId = 123456,
    int modelId = 789,
    String modelName = 'Test Model',
    String? versionName = 'v1.0',
    String? baseModel = 'SD 1.5',
    String? modelType = 'Checkpoint',
    int fileCount = 3,
    double totalSizeKb = 7168000.0,
    String modelJson = '{"id":789,"name":"Test Model"}',
    String versionJson = '{"id":123456,"name":"v1.0"}',
    MagazineItemStatus status = MagazineItemStatus.pending,
    int retryCount = 0,
    String? errorMessage,
    DateTime? loadedAt,
    DateTime? firedAt,
  }) {
    return MagazineItem(
      id: id,
      modelVersionId: modelVersionId,
      modelId: modelId,
      modelName: modelName,
      versionName: versionName,
      baseModel: baseModel,
      modelType: modelType,
      fileCount: fileCount,
      totalSizeKb: totalSizeKb,
      modelJson: modelJson,
      versionJson: versionJson,
      status: status,
      retryCount: retryCount,
      errorMessage: errorMessage,
      loadedAt: loadedAt ?? DateTime.parse('2026-06-07T10:00:00.000'),
      firedAt: firedAt,
    );
  }

  // =========================================================================
  // Insert
  // =========================================================================
  group('DownloadMagazineDatabase.insert', () {
    test('persists a round and returns it', () async {
      // TODO: Replace with actual DownloadMagazineDatabase once created
      final db = await CivitaiDatabase.instance;
      final item = sampleItem();

      // Insert the row manually for now (will be replaced by DownloadMagazineDatabase.insert)
      await db.db.insert('download_magazine', item.toRow()..remove('id'));
      final rows = await db.db.query('download_magazine');
      expect(rows.length, 1);
      expect(rows.first['model_version_id'], 123456);
      expect(rows.first['model_name'], 'Test Model');
    });

    test('rejects duplicate model_version_id', () async {
      final db = await CivitaiDatabase.instance;
      final item = sampleItem();

      await db.db.insert('download_magazine', item.toRow()..remove('id'));

      // Second insert with same model_version_id should fail
      try {
        await db.db.insert(
          'download_magazine',
          sampleItem(modelVersionId: 123456).toRow()..remove('id'),
        );
        fail('Expected unique constraint violation');
      } catch (_) {
        // Expected
      }
    });
  });

  // =========================================================================
  // Query
  // =========================================================================
  group('DownloadMagazineDatabase queries', () {
    test('loadAll returns all rows ordered by id', () async {
      final db = await CivitaiDatabase.instance;
      await db.db.insert(
        'download_magazine',
        sampleItem(modelVersionId: 100).toRow()..remove('id'),
      );
      await db.db.insert(
        'download_magazine',
        sampleItem(modelVersionId: 200, modelName: 'Second').toRow()
          ..remove('id'),
      );

      final rows = await db.db.query('download_magazine', orderBy: 'id');
      expect(rows.length, 2);
      expect(rows.first['model_version_id'], 100);
      expect(rows.last['model_version_id'], 200);
    });

    test('loadPending returns only status=pending', () async {
      final db = await CivitaiDatabase.instance;
      await db.db.insert(
        'download_magazine',
        sampleItem(modelVersionId: 100).toRow()..remove('id'),
      );
      await db.db.insert(
        'download_magazine',
        sampleItem(
          modelVersionId: 200,
          status: MagazineItemStatus.failed,
          retryCount: 3,
          errorMessage: 'Timeout',
        ).toRow()..remove('id'),
      );

      final rows = await db.db.query(
        'download_magazine',
        where: 'status = ?',
        whereArgs: ['pending'],
        orderBy: 'id',
      );
      expect(rows.length, 1);
      expect(rows.first['model_version_id'], 100);
    });

    test('loadFiring returns the firing round', () async {
      final db = await CivitaiDatabase.instance;
      await db.db.insert(
        'download_magazine',
        sampleItem(
          modelVersionId: 100,
          status: MagazineItemStatus.firing,
        ).toRow()..remove('id'),
      );
      await db.db.insert(
        'download_magazine',
        sampleItem(modelVersionId: 200).toRow()..remove('id'),
      );

      final rows = await db.db.query(
        'download_magazine',
        where: 'status = ?',
        whereArgs: ['firing'],
      );
      expect(rows.length, 1);
      expect(rows.first['model_version_id'], 100);
    });

    test('findByModelVersionId finds existing', () async {
      final db = await CivitaiDatabase.instance;
      await db.db.insert(
        'download_magazine',
        sampleItem(modelVersionId: 123).toRow()..remove('id'),
      );

      final rows = await db.db.query(
        'download_magazine',
        where: 'model_version_id = ?',
        whereArgs: [123],
      );
      expect(rows.length, 1);

      final notFound = await db.db.query(
        'download_magazine',
        where: 'model_version_id = ?',
        whereArgs: [999],
      );
      expect(notFound, isEmpty);
    });
  });

  // =========================================================================
  // Update
  // =========================================================================
  group('DownloadMagazineDatabase.update', () {
    test('updates status and retry_count', () async {
      final db = await CivitaiDatabase.instance;
      await db.db.insert(
        'download_magazine',
        sampleItem(modelVersionId: 100).toRow()..remove('id'),
      );

      await db.db.update(
        'download_magazine',
        {'status': 'failed', 'retry_count': 3, 'error_message': 'Boom'},
        where: 'model_version_id = ?',
        whereArgs: [100],
      );

      final row = await db.db.query(
        'download_magazine',
        where: 'model_version_id = ?',
        whereArgs: [100],
      );
      expect(row.first['status'], 'failed');
      expect(row.first['retry_count'], 3);
      expect(row.first['error_message'], 'Boom');
    });

    test('resetFiringToPending preserves retry_count', () async {
      final db = await CivitaiDatabase.instance;
      await db.db.insert(
        'download_magazine',
        sampleItem(
          modelVersionId: 100,
          status: MagazineItemStatus.firing,
          retryCount: 2,
        ).toRow()..remove('id'),
      );

      await db.db.update(
        'download_magazine',
        {'status': 'pending'},
        where: 'model_version_id = ?',
        whereArgs: [100],
      );

      final row = await db.db.query(
        'download_magazine',
        where: 'model_version_id = ?',
        whereArgs: [100],
      );
      expect(row.first['status'], 'pending');
      expect(row.first['retry_count'], 2); // preserved
    });
  });

  // =========================================================================
  // Delete & Clear
  // =========================================================================
  group('DownloadMagazineDatabase delete & clear', () {
    test('delete removes a round', () async {
      final db = await CivitaiDatabase.instance;
      await db.db.insert(
        'download_magazine',
        sampleItem(modelVersionId: 100).toRow()..remove('id'),
      );

      await db.db.delete(
        'download_magazine',
        where: 'model_version_id = ?',
        whereArgs: [100],
      );

      final rows = await db.db.query('download_magazine');
      expect(rows, isEmpty);
    });

    test('clear removes all non-firing rounds', () async {
      final db = await CivitaiDatabase.instance;
      await db.db.insert(
        'download_magazine',
        sampleItem(modelVersionId: 100).toRow()..remove('id'),
      );
      await db.db.insert(
        'download_magazine',
        sampleItem(
          modelVersionId: 200,
          status: MagazineItemStatus.failed,
        ).toRow()..remove('id'),
      );
      await db.db.insert(
        'download_magazine',
        sampleItem(
          modelVersionId: 300,
          status: MagazineItemStatus.firing,
        ).toRow()..remove('id'),
      );

      await db.db.delete(
        'download_magazine',
        where: 'status != ?',
        whereArgs: ['firing'],
      );

      final remaining = await db.db.query('download_magazine');
      expect(remaining.length, 1);
      expect(remaining.first['model_version_id'], 300);
      expect(remaining.first['status'], 'firing');
    });

    test('round-trip MagazineItem through fromRow/toRow with DB', () async {
      final db = await CivitaiDatabase.instance;
      final original = sampleItem(
        modelVersionId: 999,
        versionName: null,
        baseModel: null,
        errorMessage: null,
        firedAt: null,
      );

      await db.db.insert('download_magazine', original.toRow()..remove('id'));
      final rows = await db.db.query('download_magazine');
      final restored = MagazineItem.fromRow(rows.first);

      expect(restored.modelVersionId, original.modelVersionId);
      expect(restored.modelName, original.modelName);
      expect(restored.versionName, isNull);
      expect(restored.baseModel, isNull);
      expect(restored.status, original.status);
      expect(restored.loadedAt, original.loadedAt);
    });
  });
}
