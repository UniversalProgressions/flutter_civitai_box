import 'package:sqflite/sqflite.dart';

import '../database.dart';

final class ModelTypeDao {
  const ModelTypeDao();

  Future<Database> get _db async => (await CivitaiDatabase.instance).db;

  Future<int> insert(Map<String, Object?> row) => _db.then(
    (db) => db.insert(
      'model_type',
      row,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    ),
  );

  Future<int> upsert(Map<String, Object?> row) => _db.then(
    (db) => db.insert(
      'model_type',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    ),
  );

  Future<void> upsertAll(List<Map<String, Object?>> rows) async {
    final db = await _db;
    final batch = db.batch();
    for (final row in rows) {
      batch.insert(
        'model_type',
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<Map<String, Object?>?> getById(int id) => _db.then(
    (db) => db
        .query('model_type', where: 'id = ?', whereArgs: [id])
        .then((r) => r.isEmpty ? null : r.first),
  );

  Future<Map<String, Object?>?> getByName(String name) => _db.then(
    (db) => db
        .query('model_type', where: 'name = ?', whereArgs: [name])
        .then((r) => r.isEmpty ? null : r.first),
  );

  Future<List<Map<String, Object?>>> getAll() =>
      _db.then((db) => db.query('model_type'));

  Future<int> delete(int id) => _db.then(
    (db) => db.delete('model_type', where: 'id = ?', whereArgs: [id]),
  );
}
