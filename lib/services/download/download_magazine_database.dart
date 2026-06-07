import 'package:flutter_civitai_box/db/database.dart';
import 'package:flutter_civitai_box/services/download/download_magazine_item.dart';
import 'package:sqflite/sqflite.dart';

/// CRUD operations for the `download_magazine` table.
///
/// All methods operate on the singleton [CivitaiDatabase] instance.
class DownloadMagazineDatabase {
  const DownloadMagazineDatabase();

  // ---------------------------------------------------------------------------
  // Insert
  // ---------------------------------------------------------------------------

  /// Insert a round into the magazine.
  ///
  /// Throws if a round with the same [MagazineItem.modelVersionId] already
  /// exists (UNIQUE constraint on `model_version_id`).
  Future<MagazineItem> insert(MagazineItem item) async {
    final db = await _db;
    final row = Map<String, Object?>.from(item.toRow());
    row.remove('id'); // Let SQLite auto-increment

    final id = await db.insert('download_magazine', row);
    return item.copyWith(id: id);
  }

  // ---------------------------------------------------------------------------
  // Query
  // ---------------------------------------------------------------------------

  /// Get all rounds, ordered by insertion (id).
  Future<List<MagazineItem>> loadAll() async {
    final db = await _db;
    final rows = await db.query('download_magazine', orderBy: 'id');
    return rows.map(MagazineItem.fromRow).toList();
  }

  /// Get all rounds with status = 'pending', ordered by insertion.
  Future<List<MagazineItem>> loadPending() async {
    final db = await _db;
    final rows = await db.query(
      'download_magazine',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'id',
    );
    return rows.map(MagazineItem.fromRow).toList();
  }

  /// Get the round currently being fired (at most one).
  Future<MagazineItem?> loadFiring() async {
    final db = await _db;
    final rows = await db.query(
      'download_magazine',
      where: 'status = ?',
      whereArgs: ['firing'],
      limit: 1,
    );
    return rows.isEmpty ? null : MagazineItem.fromRow(rows.first);
  }

  /// Find a round by its [modelVersionId].
  Future<MagazineItem?> findByModelVersionId(int modelVersionId) async {
    final db = await _db;
    final rows = await db.query(
      'download_magazine',
      where: 'model_version_id = ?',
      whereArgs: [modelVersionId],
      limit: 1,
    );
    return rows.isEmpty ? null : MagazineItem.fromRow(rows.first);
  }

  // ---------------------------------------------------------------------------
  // Crash Recovery
  // ---------------------------------------------------------------------------

  /// Find any round stuck in 'firing' status (crash recovery).
  Future<MagazineItem?> findFiringRound() => loadFiring();

  /// Reset a 'firing' round back to 'pending', preserving [MagazineItem.retryCount].
  Future<void> resetFiringToPending(int id) async {
    final db = await _db;
    await db.update(
      'download_magazine',
      {'status': 'pending'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  /// Update a round's mutable fields in the database.
  ///
  /// Updates: [MagazineItemStatus], [MagazineItem.retryCount],
  /// [MagazineItem.errorMessage], [MagazineItem.firedAt].
  Future<void> update(MagazineItem item) async {
    final db = await _db;
    await db.update(
      'download_magazine',
      {
        'status': item.status.name,
        'retry_count': item.retryCount,
        'error_message': item.errorMessage,
        'fired_at': item.firedAt?.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// Skip a failed round — mark as 'skipped'.
  Future<void> skipFailedRound(int id) async {
    final db = await _db;
    await db.update(
      'download_magazine',
      {'status': 'skipped'},
      where: 'id = ? AND status = ?',
      whereArgs: [id, 'failed'],
    );
  }

  /// Retry a failed round — reset to 'pending' with retry_count = 0.
  Future<void> retryFailedRound(int id) async {
    final db = await _db;
    await db.update(
      'download_magazine',
      {'status': 'pending', 'retry_count': 0},
      where: 'id = ? AND status = ?',
      whereArgs: [id, 'failed'],
    );
  }

  // ---------------------------------------------------------------------------
  // Delete & Clear
  // ---------------------------------------------------------------------------

  /// Remove a single round by its magazine [id].
  Future<void> remove(int id) async {
    final db = await _db;
    await db.delete('download_magazine', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete a round by its magazine [id] (alias for [remove]).
  Future<void> delete(int id) => remove(id);

  /// Clear all rounds except the one currently firing.
  Future<void> clear() async {
    final db = await _db;
    await db.delete(
      'download_magazine',
      where: 'status != ?',
      whereArgs: ['firing'],
    );
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  Future<Database> get _db async => (await CivitaiDatabase.instance).db;
}
