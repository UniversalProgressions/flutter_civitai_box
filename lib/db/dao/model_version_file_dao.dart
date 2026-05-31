import 'package:sqflite/sqflite.dart';

import '../database.dart';

final class ModelVersionFileDao {
  const ModelVersionFileDao();

  Future<Database> get _db async => (await CivitaiDatabase.instance).db;

  Future<int> insert(Map<String, Object?> row) => _db.then(
    (db) => db.insert(
      'model_version_file',
      row,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    ),
  );

  Future<int> upsert(Map<String, Object?> row) => _db.then(
    (db) => db.insert(
      'model_version_file',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    ),
  );

  Future<void> upsertAll(List<Map<String, Object?>> rows) async {
    final db = await _db;
    final batch = db.batch();
    for (final row in rows) {
      batch.insert(
        'model_version_file',
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<Map<String, Object?>?> getById(int id) => _db.then(
    (db) => db
        .query('model_version_file', where: 'id = ?', whereArgs: [id])
        .then((r) => r.isEmpty ? null : r.first),
  );

  Future<List<Map<String, Object?>>> getByModelVersion(int versionId) =>
      _db.then(
        (db) => db.query(
          'model_version_file',
          where: 'model_version_id = ?',
          whereArgs: [versionId],
        ),
      );

  Future<List<Map<String, Object?>>> getAll() =>
      _db.then((db) => db.query('model_version_file'));

  Future<int> delete(int id) => _db.then(
    (db) => db.delete('model_version_file', where: 'id = ?', whereArgs: [id]),
  );

  Future<int> deleteByModelVersion(int versionId) => _db.then(
    (db) => db.delete(
      'model_version_file',
      where: 'model_version_id = ?',
      whereArgs: [versionId],
    ),
  );
}
