import 'package:sqflite/sqflite.dart';

import '../database.dart';

final class UserCustomTagDao {
  const UserCustomTagDao();

  Future<Database> get _db async => (await CivitaiDatabase.instance).db;

  /// Insert a tag (ignores duplicates per UNIQUE constraint).
  Future<int> insert(Map<String, Object?> row) => _db.then(
    (db) => db.insert(
      'user_custom_tag',
      row,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    ),
  );

  /// Replace tags for a model version: delete all existing, then insert [tags].
  Future<void> replaceTags(
    int modelId,
    int modelVersionId,
    List<String> tags,
  ) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(
        'user_custom_tag',
        where: 'model_version_id = ?',
        whereArgs: [modelVersionId],
      );
      for (final tag in tags) {
        await txn.insert('user_custom_tag', {
          'model_id': modelId,
          'model_version_id': modelVersionId,
          'tag_name': tag,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }

  /// Get all custom tags for a model version.
  Future<List<Map<String, Object?>>> getByVersion(int modelVersionId) =>
      _db.then(
        (db) => db.query(
          'user_custom_tag',
          where: 'model_version_id = ?',
          whereArgs: [modelVersionId],
          orderBy: 'tag_name',
        ),
      );

  /// Get all custom tags for a model (across all versions).
  Future<List<Map<String, Object?>>> getByModel(int modelId) => _db.then(
    (db) => db.query(
      'user_custom_tag',
      where: 'model_id = ?',
      whereArgs: [modelId],
      orderBy: 'tag_name',
    ),
  );

  /// Delete all custom tags for a model version.
  Future<int> deleteByVersion(int modelVersionId) => _db.then(
    (db) => db.delete(
      'user_custom_tag',
      where: 'model_version_id = ?',
      whereArgs: [modelVersionId],
    ),
  );
}
