import 'package:sqflite/sqflite.dart';

import '../../db/database.dart';
import 'download_task.dart';

/// CRUD operations for the `download_task` table.
class DownloadDatabase {
  const DownloadDatabase();

  Future<Database> get _db async => (await CivitaiDatabase.instance).db;

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  /// Insert a single task.
  ///
  /// Uses [ConflictAlgorithm.ignore]: if a task for the same
  /// (model_version_id, target_path) already exists, the new row is skipped
  /// (idempotency safety net).
  Future<void> insert(DownloadTask task) async {
    final db = await _db;
    await db.insert(
      'download_task',
      task.toRow(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Insert multiple tasks in one transaction.
  Future<void> insertAll(List<DownloadTask> tasks) async {
    if (tasks.isEmpty) return;
    final db = await _db;
    final batch = db.batch();
    for (final t in tasks) {
      batch.insert(
        'download_task',
        t.toRow(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Update task status and progress.
  Future<void> update(DownloadTask task) async {
    final db = await _db;
    await db.update(
      'download_task',
      {
        'status': task.status.name,
        'progress': task.progress,
        'error_message': task.errorMessage,
        'background_task_id': task.backgroundTaskId,
        'updated_at': task.updatedAt,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Load all active tasks (not completed, not cancelled).
  Future<List<DownloadTask>> loadActive() async {
    final db = await _db;
    final rows = await db.rawQuery(
      "SELECT * FROM download_task WHERE status IN ('pending','downloading','failed') ORDER BY created_at",
    );
    return rows.map(DownloadTask.fromRow).toList();
  }

  /// Load all tasks, newest first.
  Future<List<DownloadTask>> loadAll() async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT * FROM download_task ORDER BY created_at DESC',
    );
    return rows.map(DownloadTask.fromRow).toList();
  }

  /// Load tasks for a specific batch.
  Future<List<DownloadTask>> loadByBatch(String batchId) async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT * FROM download_task WHERE batch_id = ? ORDER BY created_at',
      [batchId],
    );
    return rows.map(DownloadTask.fromRow).toList();
  }

  /// Check if a batch exists and is not all completed/cancelled.
  Future<bool> hasActiveBatch(int modelVersionId) async {
    final db = await _db;
    final rows = await db.rawQuery(
      "SELECT COUNT(*) as cnt FROM download_task WHERE model_version_id = ? AND status NOT IN ('completed','cancelled')",
      [modelVersionId],
    );
    return (rows.first['cnt'] as int) > 0;
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  /// Delete all completed/cancelled tasks (cleanup history).
  Future<void> deleteCompleted() async {
    final db = await _db;
    await db.delete(
      'download_task',
      where: "status IN ('completed','cancelled')",
    );
  }

  /// Delete a specific batch.
  Future<void> deleteBatch(String batchId) async {
    final db = await _db;
    await db.delete(
      'download_task',
      where: 'batch_id = ?',
      whereArgs: [batchId],
    );
  }
}
