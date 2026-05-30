import 'package:sqflite/sqflite.dart';

import '../database.dart';

final class ModelVersionDao {
  const ModelVersionDao();

  Future<Database> get _db async => (await CivitaiDatabase.instance).db;

  Future<int> insert(Map<String, Object?> row) => _db.then(
    (db) => db.insert(
      'model_version',
      row,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    ),
  );

  Future<int> upsert(Map<String, Object?> row) => _db.then(
    (db) => db.insert(
      'model_version',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    ),
  );

  Future<void> upsertAll(List<Map<String, Object?>> rows) async {
    final db = await _db;
    final batch = db.batch();
    for (final row in rows) {
      batch.insert(
        'model_version',
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<Map<String, Object?>?> getById(int id) => _db.then(
    (db) => db
        .query('model_version', where: 'id = ?', whereArgs: [id])
        .then((r) => r.isEmpty ? null : r.first),
  );

  Future<List<Map<String, Object?>>> getByModel(int modelId) => _db.then(
    (db) =>
        db.query('model_version', where: 'model_id = ?', whereArgs: [modelId]),
  );

  Future<List<Map<String, Object?>>> getByBaseModel(int baseModelId) =>
      _db.then(
        (db) => db.query(
          'model_version',
          where: 'base_model_id = ?',
          whereArgs: [baseModelId],
        ),
      );

  Future<List<Map<String, Object?>>> getAll() =>
      _db.then((db) => db.query('model_version'));

  Future<int> delete(int id) => _db.then(
    (db) => db.delete('model_version', where: 'id = ?', whereArgs: [id]),
  );

  /// Delete all versions belonging to a model (cascades to files/images).
  Future<int> deleteByModel(int modelId) => _db.then(
    (db) =>
        db.delete('model_version', where: 'model_id = ?', whereArgs: [modelId]),
  );
}
