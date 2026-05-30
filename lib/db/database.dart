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
      version: 1,
      onCreate: _onCreate,
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
      version: 1,
      onCreate: _instance!._onCreate,
      onConfigure: _instance!._onConfigure,
    );
    return _instance!;
  }
}
