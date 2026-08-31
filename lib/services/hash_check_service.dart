import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart' as crypto;
import 'package:sqflite/sqflite.dart';

import '../db/database.dart';
import '../src/rust/api/simple.dart';
import 'file_layout.dart';
import '../settings/settings.dart';

/// Result of checking a single file's hash.
enum HashCheckStatus { passed, mismatch, missing, skipped }

class HashCheckFileResult {
  final int fileId;
  final String fileName;
  final String? modelType;
  final int modelId;
  final int modelVersionId;
  final HashCheckStatus status;
  final String? algorithm;
  final String? expectedHash;
  final String? actualHash;
  final double sizeKB;

  const HashCheckFileResult({
    required this.fileId,
    required this.fileName,
    this.modelType,
    required this.modelId,
    required this.modelVersionId,
    required this.status,
    this.algorithm,
    this.expectedHash,
    this.actualHash,
    required this.sizeKB,
  });

  String get sizeFormatted {
    if (sizeKB >= 1024 * 1024) {
      return '${(sizeKB / (1024 * 1024)).toStringAsFixed(1)} GB';
    }
    if (sizeKB >= 1024) {
      return '${(sizeKB / 1024).toStringAsFixed(0)} MB';
    }
    return '${sizeKB.toStringAsFixed(0)} KB';
  }
}

/// Progress event emitted during hash checking.
class HashCheckProgress {
  final int total;
  final int checked;
  final String? currentFile;
  final List<HashCheckFileResult> results;

  const HashCheckProgress({
    required this.total,
    required this.checked,
    this.currentFile,
    required this.results,
  });

  int get passed =>
      results.where((r) => r.status == HashCheckStatus.passed).length;
  int get mismatched =>
      results.where((r) => r.status == HashCheckStatus.mismatch).length;
  int get missing =>
      results.where((r) => r.status == HashCheckStatus.missing).length;
  int get skipped =>
      results.where((r) => r.status == HashCheckStatus.skipped).length;
  bool get isDone => checked >= total;
}

/// Service that verifies model file SHA256 hashes against the expected
/// values stored in the CivitAI API JSON.
///
/// Uses parallel batch processing for speed. Default concurrency of 4
/// balances disk I/O and CPU across typical quad-core machines.
class HashCheckService {
  final int concurrency;

  const HashCheckService({this.concurrency = 4});

  Future<Database> get _db async => (await CivitaiDatabase.instance).db;

  // ---------------------------------------------------------------------------
  // Check ALL files
  // ---------------------------------------------------------------------------
  Stream<HashCheckProgress> checkAll() async* {
    final db = await _db;
    final settings = await SettingsService.getInstance();
    final basePath = settings.settingsOrNull?.basePath ?? '';

    final rows = await db.rawQuery('''
      SELECT mvf.id, mvf.name, mvf.size_kb, mvf.model_version_id,
             mv.model_id, mv.json AS version_json,
             mt.name AS model_type_name
      FROM model_version_file mvf
      JOIN model_version mv ON mv.id = mvf.model_version_id
      JOIN model m ON m.id = mv.model_id
      JOIN model_type mt ON mt.id = m.type_id
      ORDER BY mvf.id
    ''');

    yield* _processRows(rows, basePath);
  }

  // ---------------------------------------------------------------------------
  // Check files for a specific model version
  // ---------------------------------------------------------------------------
  Stream<HashCheckProgress> checkVersion({required int modelVersionId}) async* {
    final db = await _db;
    final settings = await SettingsService.getInstance();
    final basePath = settings.settingsOrNull?.basePath ?? '';

    final rows = await db.rawQuery(
      '''
      SELECT mvf.id, mvf.name, mvf.size_kb, mvf.model_version_id,
             mv.model_id, mv.json AS version_json,
             mt.name AS model_type_name
      FROM model_version_file mvf
      JOIN model_version mv ON mv.id = mvf.model_version_id
      JOIN model m ON m.id = mv.model_id
      JOIN model_type mt ON mt.id = m.type_id
      WHERE mvf.model_version_id = ?
      ORDER BY mvf.id
    ''',
      [modelVersionId],
    );

    yield* _processRows(rows, basePath);
  }

  // ---------------------------------------------------------------------------
  // Core processing — parallel batches
  // ---------------------------------------------------------------------------
  Stream<HashCheckProgress> _processRows(
    List<Map<String, dynamic>> rows,
    String basePath,
  ) async* {
    final results = <HashCheckFileResult>[];
    final total = rows.length;

    // 1) Pre-process all rows into tasks (fast, no I/O)
    final tasks = <_FileTask>[];
    for (final row in rows) {
      final fileId = row['id'] as int;
      final fileName = row['name'] as String? ?? '';
      final sizeKb = (row['size_kb'] as num?)?.toDouble() ?? 0;
      final versionJsonStr = row['version_json'] as String?;

      _Hashes? hashes;
      if (versionJsonStr != null && versionJsonStr.isNotEmpty) {
        hashes = _extractHashesFromJson(versionJsonStr, fileName);
      }

      if (hashes == null) {
        results.add(
          HashCheckFileResult(
            fileId: fileId,
            fileName: fileName,
            modelType: row['model_type_name'] as String?,
            modelId: row['model_id'] as int,
            modelVersionId: row['model_version_id'] as int,
            status: HashCheckStatus.skipped,
            sizeKB: sizeKb,
          ),
        );
      } else {
        final filePath = _buildFilePath(
          basePath,
          (row['model_type_name'] as String?) ?? '',
          row['model_id'] as int,
          row['model_version_id'] as int,
          fileName,
        );
        tasks.add(
          _FileTask(
            fileId: fileId,
            fileName: fileName,
            modelType: row['model_type_name'] as String?,
            modelId: row['model_id'] as int,
            modelVersionId: row['model_version_id'] as int,
            blake3Hash: hashes.blake3,
            sha256Hash: hashes.sha256,
            filePath: filePath,
            sizeKb: sizeKb,
          ),
        );
      }
    }
    var checked = results.length;
    if (tasks.isEmpty) {
      yield HashCheckProgress(
        total: total,
        checked: checked,
        currentFile: null,
        results: List.of(results),
      );
      return;
    }

    // 2) Process tasks in parallel batches
    for (var i = 0; i < tasks.length; i += concurrency) {
      final batch = tasks.skip(i).take(concurrency).toList();
      final batchResults = await Future.wait(
        batch.map((t) => _processOneTask(t)),
      );

      for (final r in batchResults) {
        results.add(r);
        checked++;
        yield HashCheckProgress(
          total: total,
          checked: checked,
          currentFile: r.fileName,
          results: List.of(results),
        );
      }
    }
  }

  /// Process a single file task — prefers Rust BLAKE3, falls back to SHA256.
  Future<HashCheckFileResult> _processOneTask(_FileTask task) async {
    final file = File(task.filePath);
    if (!file.existsSync()) {
      return HashCheckFileResult(
        fileId: task.fileId,
        fileName: task.fileName,
        modelType: task.modelType,
        modelId: task.modelId,
        modelVersionId: task.modelVersionId,
        status: HashCheckStatus.missing,
        expectedHash: task.blake3Hash ?? task.sha256Hash,
        sizeKB: task.sizeKb,
      );
    }

    String actual;
    String algorithm;
    try {
      if (task.blake3Hash != null) {
        try {
          // Runs on the flutter_rust_bridge thread pool — does not block UI.
          actual = await blake3HashFile(path: task.filePath);
          algorithm = 'BLAKE3';
        } catch (_) {
          if (task.sha256Hash == null) rethrow;
          actual = await Isolate.run(() => _hashFile(task.filePath));
          algorithm = 'SHA256';
        }
      } else {
        actual = await Isolate.run(() => _hashFile(task.filePath));
        algorithm = 'SHA256';
      }

      final expected = task.blake3Hash ?? task.sha256Hash!;
      final passed = actual.toLowerCase() == expected.toLowerCase();
      return HashCheckFileResult(
        fileId: task.fileId,
        fileName: task.fileName,
        modelType: task.modelType,
        modelId: task.modelId,
        modelVersionId: task.modelVersionId,
        status: passed ? HashCheckStatus.passed : HashCheckStatus.mismatch,
        algorithm: algorithm,
        expectedHash: expected,
        actualHash: actual,
        sizeKB: task.sizeKb,
      );
    } catch (_) {
      return HashCheckFileResult(
        fileId: task.fileId,
        fileName: task.fileName,
        modelType: task.modelType,
        modelId: task.modelId,
        modelVersionId: task.modelVersionId,
        status: HashCheckStatus.mismatch,
        expectedHash: task.blake3Hash ?? task.sha256Hash,
        actualHash: 'ERROR',
        sizeKB: task.sizeKb,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Extract BLAKE3 and SHA256 hashes from version JSON for a given file name.
  /// Returns null if no usable hash is found.
  _Hashes? _extractHashesFromJson(String jsonStr, String fileName) {
    try {
      final data = const JsonDecoder().convert(jsonStr) as Map<String, dynamic>;
      final files = data['files'] as List?;
      if (files == null) return null;

      for (final f in files) {
        if (f is! Map<String, dynamic>) continue;
        if ((f['name'] as String? ?? '') != fileName) continue;

        final hashes = f['hashes'] as Map<String, dynamic>?;
        if (hashes == null) return null;

        final blake3 = hashes['BLAKE3'] as String?;
        final sha256 = hashes['SHA256'] as String?;
        if (blake3 != null && blake3.isNotEmpty) {
          return _Hashes(blake3: blake3, sha256: sha256);
        }
        if (sha256 != null && sha256.isNotEmpty) {
          return _Hashes(blake3: null, sha256: sha256);
        }
        return null;
      }
    } catch (_) {}
    return null;
  }

  String _buildFilePath(
    String basePath,
    String modelType,
    int modelId,
    int modelVersionId,
    String fileName,
  ) {
    final filesDir = getFilesDir(basePath, modelType, modelId, modelVersionId);
    return '$filesDir${Platform.pathSeparator}$fileName';
  }
}

/// Pre-resolved file task for parallel processing.
class _FileTask {
  final int fileId;
  final String fileName;
  final String? modelType;
  final int modelId;
  final int modelVersionId;
  final String? blake3Hash;
  final String? sha256Hash;
  final String filePath;
  final double sizeKb;

  const _FileTask({
    required this.fileId,
    required this.fileName,
    this.modelType,
    required this.modelId,
    required this.modelVersionId,
    this.blake3Hash,
    this.sha256Hash,
    required this.filePath,
    required this.sizeKb,
  });
}

// ---------------------------------------------------------------------------
// Top-level function for Isolate.run() — must be static, not a closure.
// ---------------------------------------------------------------------------

/// Compute SHA256 of a file at [filePath] in a background isolate.
Future<String> _hashFile(String filePath) async {
  final file = File(filePath);
  final digest = await crypto.sha256.bind(file.openRead()).first;
  return digest.toString().toUpperCase();
}

/// Holds the expected hashes extracted from the version JSON.
class _Hashes {
  final String? blake3;
  final String? sha256;
  const _Hashes({this.blake3, this.sha256});
}
