import 'package:sqflite/sqflite.dart';

import '../database.dart';

final class UserCustomPreviewDao {
  const UserCustomPreviewDao();

  Future<Database> get _db async => (await CivitaiDatabase.instance).db;

  /// Upsert a custom preview image for a model version.
  Future<int> upsert(Map<String, Object?> row) => _db.then(
    (db) => db.insert(
      'user_custom_preview',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    ),
  );

  /// Get the custom preview for a specific model version.
  Future<Map<String, Object?>?> getByVersion(int modelVersionId) => _db.then(
    (db) => db
        .query(
          'user_custom_preview',
          where: 'model_version_id = ?',
          whereArgs: [modelVersionId],
        )
        .then((r) => r.isEmpty ? null : r.first),
  );

  /// Get all custom previews for a model (across all its versions).
  Future<List<Map<String, Object?>>> getByModel(int modelId) => _db.then(
    (db) => db.query(
      'user_custom_preview',
      where: 'model_id = ?',
      whereArgs: [modelId],
    ),
  );

  /// Delete the custom preview for a model version.
  Future<int> deleteByVersion(int modelVersionId) => _db.then(
    (db) => db.delete(
      'user_custom_preview',
      where: 'model_version_id = ?',
      whereArgs: [modelVersionId],
    ),
  );
}
