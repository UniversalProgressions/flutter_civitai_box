import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../database.dart';

/// High-level business logic for `model_version`, `model_version_file`,
/// and `model_version_image`.
final class ModelVersionRepository {
  const ModelVersionRepository();

  Future<Database> get _db async => (await CivitaiDatabase.instance).db;

  // ---------------------------------------------------------------------------
  // Upsert version + files + images
  // ---------------------------------------------------------------------------

  /// Upsert a full model version with its images and files.
  ///
  /// [versionJson] is the full API JSON for this version.
  /// [modelJson] is the full API JSON for the parent model.
  /// [images] and [files] are extracted from [versionJson] by the caller.
  Future<void> upsertVersion({
    required int id,
    required int modelId,
    required String name,
    required String baseModelName,
    required String? baseModelTypeName,
    required int nsfwLevel,
    required Map<String, dynamic> versionJson,
    required Map<String, dynamic> modelJson,
    required String modelName,
    required Map<String, dynamic>? creatorJson,
    required String modelTypeName,
    required List<String> tagNames,
    required bool modelNsfw,
    required int modelNsfwLevel,
    required List<Map<String, dynamic>> images,
    required List<Map<String, dynamic>> files,
    bool checkFileExistence = false,
    String? basePath,
  }) async {
    final db = await _db;

    await db.transaction((txn) async {
      // 1) Find-or-create base model
      int baseModelId;
      final bmRows = await txn.rawQuery(
        'SELECT id FROM base_model WHERE name = ?',
        [baseModelName],
      );
      if (bmRows.isNotEmpty) {
        baseModelId = bmRows.first['id'] as int;
      } else {
        baseModelId = await txn.rawInsert(
          'INSERT INTO base_model (name) VALUES (?)',
          [baseModelName],
        );
      }

      // 2) Find-or-create base model type (if provided)
      int? baseModelTypeId;
      if (baseModelTypeName != null && baseModelTypeName.isNotEmpty) {
        final bmtRows = await txn.rawQuery(
          'SELECT id FROM base_model_type WHERE name = ?',
          [baseModelTypeName],
        );
        if (bmtRows.isNotEmpty) {
          baseModelTypeId = bmtRows.first['id'] as int;
        } else {
          baseModelTypeId = await txn.rawInsert(
            'INSERT INTO base_model_type (name, base_model_id) VALUES (?, ?)',
            [baseModelTypeName, baseModelId],
          );
        }
      }

      // 3) Upsert parent model (delegate to ModelRepository via raw SQL to stay
      //    inside this transaction)
      await _upsertModelInTxn(
        txn,
        id: modelId,
        name: modelName,
        creatorJson: creatorJson,
        modelTypeName: modelTypeName,
        tagNames: tagNames,
        nsfw: modelNsfw,
        nsfwLevel: modelNsfwLevel,
        modelJson: modelJson,
      );

      // 4) Upsert model version
      await txn.rawInsert(
        '''INSERT INTO model_version
           (id, model_id, name, base_model_id, base_model_type_id, nsfw_level, json, updated_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'))
           ON CONFLICT(id) DO UPDATE SET
             name=excluded.name,
             base_model_id=excluded.base_model_id,
             base_model_type_id=excluded.base_model_type_id,
             nsfw_level=excluded.nsfw_level,
             json=excluded.json,
             updated_at=datetime('now')''',
        [
          id,
          modelId,
          name,
          baseModelId,
          baseModelTypeId,
          nsfwLevel,
          jsonEncode(versionJson),
        ],
      );

      // 5) Upsert images
      for (final img in images) {
        await txn.rawInsert(
          '''INSERT INTO model_version_image
             (id, url, nsfw_level, width, height, hash, type, model_version_id)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)
             ON CONFLICT(id) DO UPDATE SET
               url=excluded.url, nsfw_level=excluded.nsfw_level,
               width=excluded.width, height=excluded.height,
               hash=excluded.hash, type=excluded.type''',
          [
            img['id'],
            img['url'],
            img['nsfwLevel'],
            img['width'],
            img['height'],
            img['hash'],
            img['type'],
            id,
          ],
        );
      }

      // 6) Upsert files
      for (final f in files) {
        await txn.rawInsert(
          '''INSERT INTO model_version_file
             (id, size_kb, name, type, download_url, model_version_id)
             VALUES (?, ?, ?, ?, ?, ?)
             ON CONFLICT(id) DO UPDATE SET
               size_kb=excluded.size_kb, name=excluded.name,
               type=excluded.type, download_url=excluded.download_url''',
          [f['id'], f['sizeKB'], f['name'], f['type'], f['downloadUrl'], id],
        );
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  /// Delete a single model version.  If the parent model has no versions left,
  /// the model itself is also deleted.
  ///
  /// Returns metadata about what was removed.
  Future<({bool deleted, bool modelDeleted, int fileCount, int imageCount})>
  deleteVersion(int versionId) async {
    final db = await _db;

    return db.transaction((txn) async {
      // Count files & images before deletion
      final fileCountRow = await txn.rawQuery(
        'SELECT COUNT(*) AS cnt FROM model_version_file WHERE model_version_id = ?',
        [versionId],
      );
      final imageCountRow = await txn.rawQuery(
        'SELECT COUNT(*) AS cnt FROM model_version_image WHERE model_version_id = ?',
        [versionId],
      );
      final fileCount = (fileCountRow.first['cnt'] as int?) ?? 0;
      final imageCount = (imageCountRow.first['cnt'] as int?) ?? 0;

      // Find the parent model id
      final versionRow = await txn.rawQuery(
        'SELECT model_id FROM model_version WHERE id = ?',
        [versionId],
      );
      if (versionRow.isEmpty) {
        throw Exception('Model version $versionId not found');
      }
      final modelId = versionRow.first['model_id'] as int;

      // Delete the version (CASCADE will remove files & images)
      await txn.rawDelete('DELETE FROM model_version WHERE id = ?', [
        versionId,
      ]);

      // If no versions remain, delete the model too
      final remainingRow = await txn.rawQuery(
        'SELECT COUNT(*) AS cnt FROM model_version WHERE model_id = ?',
        [modelId],
      );
      bool modelDeleted = false;
      if ((remainingRow.first['cnt'] as int) == 0) {
        await txn.rawDelete('DELETE FROM model WHERE id = ?', [modelId]);
        modelDeleted = true;
      }

      return (
        deleted: true,
        modelDeleted: modelDeleted,
        fileCount: fileCount,
        imageCount: imageCount,
      );
    });
  }

  /// Batch-delete multiple model versions.  Collects per-version results
  /// (including errors) and never throws.
  Future<
    ({
      int total,
      int succeeded,
      int failed,
      List<
        ({
          int versionId,
          bool success,
          String? error,
          bool? modelDeleted,
          int fileCount,
          int imageCount,
        })
      >
      results,
    })
  >
  deleteMultipleVersions(List<int> versionIds) async {
    final results =
        <
          ({
            int versionId,
            bool success,
            String? error,
            bool? modelDeleted,
            int fileCount,
            int imageCount,
          })
        >[];
    int succeeded = 0;
    int failed = 0;

    for (final vid in versionIds) {
      try {
        final r = await deleteVersion(vid);
        results.add((
          versionId: vid,
          success: true,
          error: null,
          modelDeleted: r.modelDeleted,
          fileCount: r.fileCount,
          imageCount: r.imageCount,
        ));
        succeeded++;
      } catch (e) {
        results.add((
          versionId: vid,
          success: false,
          error: '$e',
          modelDeleted: null,
          fileCount: 0,
          imageCount: 0,
        ));
        failed++;
      }
    }

    return (
      total: versionIds.length,
      succeeded: succeeded,
      failed: failed,
      results: results,
    );
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Inline version of ModelRepository.upsertModel that runs inside [txn].
  Future<void> _upsertModelInTxn(
    Transaction txn, {
    required int id,
    required String name,
    required Map<String, dynamic>? creatorJson,
    required String modelTypeName,
    required List<String> tagNames,
    required bool nsfw,
    required int nsfwLevel,
    required Map<String, dynamic> modelJson,
  }) async {
    // Creator
    int? creatorId;
    if (creatorJson != null && creatorJson['username'] != null) {
      final rows = await txn.rawQuery(
        'SELECT id FROM creator WHERE username = ?',
        [creatorJson['username']],
      );
      if (rows.isNotEmpty) {
        creatorId = rows.first['id'] as int;
        await txn.rawUpdate(
          '''UPDATE creator SET link = COALESCE(?, link), image = COALESCE(?, image)
             WHERE id = ?''',
          [creatorJson['link'], creatorJson['image'], creatorId],
        );
      } else {
        creatorId = await txn.rawInsert(
          '''INSERT INTO creator (username, link, image) VALUES (?, ?, ?)''',
          [creatorJson['username'], creatorJson['link'], creatorJson['image']],
        );
      }
    }

    // Model type
    final typeRows = await txn.rawQuery(
      'SELECT id FROM model_type WHERE name = ?',
      [modelTypeName],
    );
    int typeId;
    if (typeRows.isNotEmpty) {
      typeId = typeRows.first['id'] as int;
    } else {
      typeId = await txn.rawInsert('INSERT INTO model_type (name) VALUES (?)', [
        modelTypeName,
      ]);
    }

    // Model
    await txn.rawInsert(
      '''INSERT INTO model (id, name, creator_id, type_id, nsfw, nsfw_level, json, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'))
         ON CONFLICT(id) DO UPDATE SET
           name=excluded.name,
           creator_id=excluded.creator_id,
           type_id=excluded.type_id,
           nsfw=excluded.nsfw,
           nsfw_level=excluded.nsfw_level,
           json=excluded.json,
           updated_at=datetime('now')''',
      [
        id,
        name,
        creatorId,
        typeId,
        nsfw ? 1 : 0,
        nsfwLevel,
        jsonEncode(modelJson),
      ],
    );

    // Tags
    if (tagNames.isNotEmpty) {
      for (final tag in tagNames) {
        await txn.rawInsert('INSERT OR IGNORE INTO tag (name) VALUES (?)', [
          tag,
        ]);
      }
      await txn.rawDelete('DELETE FROM model_tags WHERE model_id = ?', [id]);
      final tagRows = await txn.rawQuery(
        'SELECT id FROM tag WHERE name IN (${_placeholders(tagNames.length)})',
        tagNames,
      );
      for (final row in tagRows) {
        await txn.rawInsert(
          'INSERT OR IGNORE INTO model_tags (model_id, tag_id) VALUES (?, ?)',
          [id, row['id']],
        );
      }
    }
  }

  String _placeholders(int count) => List.filled(count, '?').join(', ');
}
