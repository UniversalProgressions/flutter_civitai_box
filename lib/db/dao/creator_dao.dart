import 'package:sqflite/sqflite.dart';

import '../database.dart';

/// Data-access object for the [creator] table.
final class CreatorDao {
  const CreatorDao();

  Future<Database> get _db async => (await CivitaiDatabase.instance).db;

  /// Insert or ignore a creator. Returns the row id.
  Future<int> insert(Map<String, Object?> row) => _db.then(
    (db) =>
        db.insert('creator', row, conflictAlgorithm: ConflictAlgorithm.ignore),
  );

  /// Insert or replace a creator by id.
  Future<int> upsert(Map<String, Object?> row) => _db.then(
    (db) =>
        db.insert('creator', row, conflictAlgorithm: ConflictAlgorithm.replace),
  );

  /// Batch-upsert a list.
  Future<void> upsertAll(List<Map<String, Object?>> rows) async {
    final db = await _db;
    final batch = db.batch();
    for (final row in rows) {
      batch.insert(
        'creator',
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<Map<String, Object?>?> getById(int id) => _db.then(
    (db) => db
        .query('creator', where: 'id = ?', whereArgs: [id])
        .then((r) => r.isEmpty ? null : r.first),
  );

  Future<List<Map<String, Object?>>> getAll() =>
      _db.then((db) => db.query('creator'));

  Future<Map<String, Object?>?> getByUsername(String username) => _db.then(
    (db) => db
        .query('creator', where: 'username = ?', whereArgs: [username])
        .then((r) => r.isEmpty ? null : r.first),
  );

  Future<int> delete(int id) =>
      _db.then((db) => db.delete('creator', where: 'id = ?', whereArgs: [id]));
}
