import 'package:sqflite/sqflite.dart';

import '../database.dart';

final class SavedSearchDao {
  const SavedSearchDao();

  Future<Database> get _db async => (await CivitaiDatabase.instance).db;

  /// Save a search preset.  Overwrites if [name] already exists.
  Future<int> upsert(String name, String json) => _db.then(
    (db) => db.insert('saved_search', {
      'name': name,
      'json': json,
    }, conflictAlgorithm: ConflictAlgorithm.replace),
  );

  Future<Map<String, Object?>?> getById(int id) => _db.then(
    (db) => db
        .query('saved_search', where: 'id = ?', whereArgs: [id])
        .then((r) => r.isEmpty ? null : r.first),
  );

  Future<Map<String, Object?>?> getByName(String name) => _db.then(
    (db) => db
        .query('saved_search', where: 'name = ?', whereArgs: [name])
        .then((r) => r.isEmpty ? null : r.first),
  );

  Future<List<Map<String, Object?>>> getAll() =>
      _db.then((db) => db.query('saved_search', orderBy: 'name'));

  Future<int> delete(int id) => _db.then(
    (db) => db.delete('saved_search', where: 'id = ?', whereArgs: [id]),
  );

  Future<int> deleteByName(String name) => _db.then(
    (db) => db.delete('saved_search', where: 'name = ?', whereArgs: [name]),
  );
}
