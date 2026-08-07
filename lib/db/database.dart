import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';

/// Central access point for the CivitAI Box SQLite database.
///
/// Usage:
/// ```dart
/// final db = await CivitaiDatabase.instance;
/// final models = await db.query('model');
/// ```
class CivitaiDatabase {
  CivitaiDatabase._();

  static CivitaiDatabase? _instance;
  static Database? _database;

  /// Singleton accessor – returns the already-opened database.
  static Future<CivitaiDatabase> get instance async {
    _instance ??= CivitaiDatabase._();
    await _instance!._init();
    return _instance!;
  }

  /// The raw sqflite [Database] handle.
  Database get db {
    if (_database == null) throw StateError('Database not initialised.');
    return _database!;
  }

  /// The file-system path to the database file.
  String get path => db.path;

  // ---------------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------------

  Future<void> _init() async {
    if (_database != null) return;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'civitai_box.db');

    _database = await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Enable foreign keys (off by default in SQLite).
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Run all CREATE TABLE statements on first launch.
  Future<void> _onCreate(Database db, int version) async {
    for (final stmt in allCreateStatements) {
      await db.execute(stmt);
    }
  }

  /// Handle database version upgrades.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(createDownloadMagazineTable);
    }
    if (oldVersion < 3) {
      // Recreate model_version_image with nullable hash column.
      await db.execute('''
        CREATE TABLE IF NOT EXISTS model_version_image_v3 (
          id                   INTEGER NOT NULL PRIMARY KEY,
          url                  TEXT    NOT NULL,
          nsfw_level           INTEGER NOT NULL,
          width                INTEGER NOT NULL,
          height               INTEGER NOT NULL,
          hash                 TEXT,
          type                 TEXT    NOT NULL,
          model_version_id     INTEGER NOT NULL,
          FOREIGN KEY (model_version_id) REFERENCES model_version(id) ON DELETE CASCADE
        )
      ''');
      await db.execute(
        'INSERT INTO model_version_image_v3 SELECT * FROM model_version_image',
      );
      await db.execute('DROP TABLE model_version_image');
      await db.execute(
        'ALTER TABLE model_version_image_v3 RENAME TO model_version_image',
      );
    }
    if (oldVersion < 4) {
      // Add display names to download_task for readable queue cards.
      await db.execute('ALTER TABLE download_task ADD COLUMN model_name TEXT');
      await db.execute(
        'ALTER TABLE download_task ADD COLUMN version_name TEXT',
      );
    }
    if (oldVersion < 5) {
      // Idempotency: deduplicate existing download_task rows (keep the latest
      // inserted row per model_version_id + target_path), then enforce
      // uniqueness going forward.
      await db.execute('''
        DELETE FROM download_task
        WHERE rowid NOT IN (
          SELECT MAX(rowid) FROM download_task
          GROUP BY model_version_id, target_path
        )
      ''');
      await db.execute('''
        CREATE UNIQUE INDEX IF NOT EXISTS idx_download_task_version_path
          ON download_task(model_version_id, target_path)
      ''');
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Convenience – close the database (useful in tests).
  Future<void> close() async {
    final d = _database;
    _database = null;
    await d?.close();
  }

  /// Open a test database at an explicit [path].
  ///
  /// Call [close] between tests and delete the file to clean up.
  static Future<CivitaiDatabase> initForTest(String path) async {
    _instance = CivitaiDatabase._();
    _database = await openDatabase(
      path,
      version: 5,
      onCreate: _instance!._onCreate,
      onUpgrade: _instance!._onUpgrade,
      onConfigure: _instance!._onConfigure,
    );
    return _instance!;
  }
}
