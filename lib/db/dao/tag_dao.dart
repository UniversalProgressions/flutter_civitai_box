import 'package:sqflite/sqflite.dart';

import '../database.dart';

final class TagDao {
  const TagDao();

  Future<Database> get _db async => (await CivitaiDatabase.instance).db;

  Future<int> insert(Map<String, Object?> row) => _db.then(
    (db) => db.insert('tag', row, conflictAlgorithm: ConflictAlgorithm.ignore),
  );

  Future<int> upsert(Map<String, Object?> row) => _db.then(
    (db) => db.insert('tag', row, conflictAlgorithm: ConflictAlgorithm.replace),
  );

  Future<void> upsertAll(List<Map<String, Object?>> rows) async {
    final db = await _db;
    final batch = db.batch();
    for (final row in rows) {
      batch.insert('tag', row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<Map<String, Object?>?> getById(int id) => _db.then(
    (db) => db
        .query('tag', where: 'id = ?', whereArgs: [id])
        .then((r) => r.isEmpty ? null : r.first),
  );

  Future<Map<String, Object?>?> getByName(String name) => _db.then(
    (db) => db
        .query('tag', where: 'name = ?', whereArgs: [name])
        .then((r) => r.isEmpty ? null : r.first),
  );

  Future<List<Map<String, Object?>>> getAll() =>
      _db.then((db) => db.query('tag'));

  /// Full-text–style search: tags whose name contains [query].
  Future<List<Map<String, Object?>>> search(String query) => _db.then(
    (db) => db.rawQuery('SELECT * FROM tag WHERE name LIKE ? COLLATE NOCASE', [
      '%$query%',
    ]),
  );

  Future<int> delete(int id) =>
      _db.then((db) => db.delete('tag', where: 'id = ?', whereArgs: [id]));
}
