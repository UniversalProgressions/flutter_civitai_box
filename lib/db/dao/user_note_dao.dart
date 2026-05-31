import 'package:sqflite/sqflite.dart';

import '../database.dart';

final class UserNoteDao {
  const UserNoteDao();

  Future<Database> get _db async => (await CivitaiDatabase.instance).db;

  // ---------------------------------------------------------------------------
  // Model-level notes (model_version_id IS NULL)
  // ---------------------------------------------------------------------------

  /// Upsert a model-level note.
  Future<int> upsertModelNote(int modelId, String content) => _db.then(
    (db) => db.insert('user_note', {
      'model_id': modelId,
      'model_version_id': null,
      'content': content,
    }, conflictAlgorithm: ConflictAlgorithm.replace),
  );

  /// Get the model-level note.
  Future<Map<String, Object?>?> getModelNote(int modelId) => _db.then(
    (db) => db
        .query(
          'user_note',
          where: 'model_id = ? AND model_version_id IS NULL',
          whereArgs: [modelId],
        )
        .then((r) => r.isEmpty ? null : r.first),
  );

  // ---------------------------------------------------------------------------
  // Version-level notes (model_version_id IS NOT NULL)
  // ---------------------------------------------------------------------------

  /// Upsert a version-level note.
  Future<int> upsertVersionNote(
    int modelId,
    int modelVersionId,
    String content,
  ) => _db.then(
    (db) => db.insert('user_note', {
      'model_id': modelId,
      'model_version_id': modelVersionId,
      'content': content,
    }, conflictAlgorithm: ConflictAlgorithm.replace),
  );

  /// Get the version-level note.
  Future<Map<String, Object?>?> getVersionNote(int modelVersionId) => _db.then(
    (db) => db
        .query(
          'user_note',
          where: 'model_version_id = ?',
          whereArgs: [modelVersionId],
        )
        .then((r) => r.isEmpty ? null : r.first),
  );

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  /// Delete the model-level note.
  Future<int> deleteModelNote(int modelId) => _db.then(
    (db) => db.delete(
      'user_note',
      where: 'model_id = ? AND model_version_id IS NULL',
      whereArgs: [modelId],
    ),
  );

  /// Delete the version-level note.
  Future<int> deleteVersionNote(int modelVersionId) => _db.then(
    (db) => db.delete(
      'user_note',
      where: 'model_version_id = ?',
      whereArgs: [modelVersionId],
    ),
  );

  /// Get all notes for a model (model-level + all version-level).
  Future<List<Map<String, Object?>>> getAllByModel(int modelId) => _db.then(
    (db) => db.query(
      'user_note',
      where: 'model_id = ?',
      whereArgs: [modelId],
      orderBy: 'model_version_id',
    ),
  );
}
