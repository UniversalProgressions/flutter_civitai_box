import 'package:sqflite/sqflite.dart';

import '../database.dart';

/// Data-access object for the [model] table + [model_tags] junction.
final class ModelDao {
  const ModelDao();

  Future<Database> get _db async => (await CivitaiDatabase.instance).db;

  // ---------------------------------------------------------------------------
  // Model rows
  // ---------------------------------------------------------------------------

  Future<int> insert(Map<String, Object?> row) => _db.then(
    (db) =>
        db.insert('model', row, conflictAlgorithm: ConflictAlgorithm.ignore),
  );

  Future<int> upsert(Map<String, Object?> row) => _db.then(
    (db) =>
        db.insert('model', row, conflictAlgorithm: ConflictAlgorithm.replace),
  );

  Future<void> upsertAll(List<Map<String, Object?>> rows) async {
    final db = await _db;
    final batch = db.batch();
    for (final row in rows) {
      batch.insert('model', row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<Map<String, Object?>?> getById(int id) => _db.then(
    (db) => db
        .query('model', where: 'id = ?', whereArgs: [id])
        .then((r) => r.isEmpty ? null : r.first),
  );

  Future<List<Map<String, Object?>>> getAll() =>
      _db.then((db) => db.query('model'));

  Future<List<Map<String, Object?>>> getByCreator(int creatorId) => _db.then(
    (db) => db.query('model', where: 'creator_id = ?', whereArgs: [creatorId]),
  );

  Future<List<Map<String, Object?>>> getByType(int typeId) => _db.then(
    (db) => db.query('model', where: 'type_id = ?', whereArgs: [typeId]),
  );

  Future<int> delete(int id) =>
      _db.then((db) => db.delete('model', where: 'id = ?', whereArgs: [id]));

  // ---------------------------------------------------------------------------
  // Model ↔ Tag junction
  // ---------------------------------------------------------------------------

  /// Link a tag to a model (ignore if already linked).
  Future<void> linkTag(int modelId, int tagId) async {
    final db = await _db;
    await db.insert('model_tags', {
      'model_id': modelId,
      'tag_id': tagId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Replace all tag links for a model atomically.
  Future<void> setTags(int modelId, List<int> tagIds) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(
        'model_tags',
        where: 'model_id = ?',
        whereArgs: [modelId],
      );
      for (final tagId in tagIds) {
        await txn.insert('model_tags', {'model_id': modelId, 'tag_id': tagId});
      }
    });
  }

  /// Get all tag ids for a model.
  Future<List<int>> getTagIds(int modelId) async {
    final db = await _db;
    final rows = await db.query(
      'model_tags',
      columns: ['tag_id'],
      where: 'model_id = ?',
      whereArgs: [modelId],
    );
    return rows.map<int>((r) => r['tag_id'] as int).toList();
  }

  /// Remove a single tag from a model.
  Future<void> unlinkTag(int modelId, int tagId) async {
    final db = await _db;
    await db.delete(
      'model_tags',
      where: 'model_id = ? AND tag_id = ?',
      whereArgs: [modelId, tagId],
    );
  }
}
