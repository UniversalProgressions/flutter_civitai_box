import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../db/db.dart';
import '../../settings/settings.dart';
import '../file_layout.dart';
import '../logger.dart';
import 'scan_result.dart';

/// Scans the models directory for files, parses their associated API JSON,
/// and upserts everything into the local database.
///
/// Emits a [ScanProgress] for every file processed via the returned [Stream].
final class ScannerService {
  const ScannerService();

  /// Supported model file extensions (mirrors the old project).
  static const _extensions = [
    '.safetensors',
    '.ckpt',
    '.pt',
    '.pth',
    '.bin',
    '.onnx',
    '.gguf',
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Scan the configured `basePath` and emit progress for each file.
  ///
  /// The stream is single-subscription.  Drain it completely to get the final
  /// [ScanResult] or cancel early.
  Stream<ScanEvent> scan() async* {
    final stopwatch = Stopwatch()..start();
    final errors = <String>[];

    // 1) Read settings
    final settingsSvc = await SettingsService.getInstance();
    final basePath = settingsSvc.settings.basePath;
    logger.info('Scan starting — basePath: $basePath');

    // 2) Find all matching files
    final files = await _findModelFiles(basePath);
    logger.info('Found ${files.length} model files on disk');

    // 3) Deduplicate: only keep unique (modelType, modelId, versionId) tuples
    final unique = <String, ModelFileInfo>{};
    for (final f in files) {
      final info = extractModelInfo(f);
      if (info == null) continue;
      final key = '${info.modelType}:${info.modelId}:${info.versionId}';
      // Prefer the first file found per version
      unique.putIfAbsent(key, () => info);
    }
    final infos = unique.values.toList();
    final total = infos.length;
    logger.info('$total unique model versions to process');

    var processed = 0;
    var upserted = 0;
    var skipped = 0;
    String? lastError;

    // 4) Process each unique version
    for (final info in infos) {
      yield ScanProgress(
        filesFound: total,
        filesProcessed: processed,
        upserted: upserted,
        skipped: skipped,
        errors: errors.length,
        currentFile: info.filePath,
        lastError: lastError,
      );

      try {
        final success = await _processOne(basePath, info);
        if (success) {
          upserted++;
          logger.info(
            '  OK  ${info.modelType}/${info.modelId}/${info.versionId}',
          );
        } else {
          skipped++;
          logger.warning(
            '  SKIP ${info.modelType}/${info.modelId}/${info.versionId} (no api-info.json)',
          );
        }
      } catch (e, st) {
        final msg = '${info.filePath}: $e';
        errors.add(msg);
        lastError = msg;
        logger.error(
          '  FAIL ${info.modelType}/${info.modelId}/${info.versionId}',
          e,
          st,
        );
      }

      processed++;
    }

    // Final progress tick
    yield ScanProgress(
      filesFound: total,
      filesProcessed: processed,
      upserted: upserted,
      skipped: skipped,
      errors: errors.length,
      lastError: lastError,
    );

    stopwatch.stop();
    logger.info(
      'Scan complete — ${stopwatch.elapsed.inSeconds}s, '
      '$upserted upserted, $skipped skipped, ${errors.length} errors',
    );
    if (errors.isNotEmpty) {
      logger.warning('First 10 errors:\n${errors.take(10).join('\n')}');
    }

    // Yield the final result as the last event
    yield ScanResult(
      filesFound: total,
      upserted: upserted,
      skipped: skipped,
      errors: errors.length,
      errorDetails: errors,
      duration: stopwatch.elapsed,
    );
  }

  // ---------------------------------------------------------------------------
  // File discovery
  // ---------------------------------------------------------------------------

  Future<List<String>> _findModelFiles(String basePath) async {
    final allFiles = <String>[];
    final extSet = _extensions.toSet();
    final root = Directory(basePath);
    if (!root.existsSync()) return allFiles;

    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final name = entity.path.toLowerCase();
        if (extSet.any((ext) => name.endsWith(ext))) {
          allFiles.add(entity.path);
        }
      }
    }
    return allFiles;
  }

  // ---------------------------------------------------------------------------
  // Per-version processing
  // ---------------------------------------------------------------------------

  /// Returns `true` if the version was upserted, `false` if it couldn't be
  /// processed (e.g. missing API JSON).
  Future<bool> _processOne(String basePath, ModelFileInfo info) async {
    // Read version-level API JSON
    final versionJsonPath = getModelVersionApiInfoJsonPath(
      basePath,
      info.modelType,
      info.modelId,
      info.versionId,
    );

    final versionFile = File(versionJsonPath);
    if (!await versionFile.exists()) return false;

    final versionJson =
        jsonDecode(await versionFile.readAsString()) as Map<String, dynamic>;

    // Read model-level API JSON (optional)
    final modelJsonPath = getModelIdApiInfoJsonPath(
      basePath,
      info.modelType,
      info.modelId,
    );
    Map<String, dynamic>? modelJson;
    final modelFile = File(modelJsonPath);
    if (await modelFile.exists()) {
      modelJson =
          jsonDecode(await modelFile.readAsString()) as Map<String, dynamic>;
    }

    final modelData =
        modelJson ?? versionJson['model'] as Map<String, dynamic>?;

    // Extract images — modelVersion endpoint images have no `id`; extract from URL
    final images = ((versionJson['images'] as List?) ?? [])
        .map<Map<String, dynamic>>((img) {
          final url = img['url'] as String;
          // Extract numeric ID from URL like ".../1743606.jpeg"
          final urlNoQuery = url.split('?').first;
          final segments = urlNoQuery.split('/');
          final lastSegment = segments.last;
          final dotIdx = lastSegment.lastIndexOf('.');
          final filename = dotIdx == -1
              ? lastSegment
              : lastSegment.substring(0, dotIdx);
          final id = int.tryParse(filename) ?? 0;
          return {
            'id': id,
            'url': url,
            'nsfwLevel': img['nsfwLevel'],
            'width': img['width'],
            'height': img['height'],
            'hash': img['hash'],
            'type': img['type'],
          };
        })
        .where((m) => m['id'] != 0)
        .toList();

    final files = ((versionJson['files'] as List?) ?? [])
        .map<Map<String, dynamic>>(
          (f) => {
            'id': f['id'],
            'sizeKB': f['sizeKB'],
            'name': f['name'],
            'type': f['type'],
            'downloadUrl': f['downloadUrl'],
          },
        )
        .toList();

    const repo = ModelVersionRepository();
    await repo.upsertVersion(
      id: versionJson['id'] as int,
      modelId: versionJson['modelId'] as int? ?? info.modelId,
      name: versionJson['name'] as String? ?? '',
      baseModelName: versionJson['baseModel'] as String? ?? '',
      baseModelTypeName: versionJson['baseModelType'] as String?,
      nsfwLevel: versionJson['nsfwLevel'] as int? ?? 0,
      versionJson: versionJson,
      modelJson: modelData ?? versionJson,
      modelName: modelData?['name'] as String? ?? '',
      creatorJson: modelData?['creator'] as Map<String, dynamic>?,
      modelTypeName: modelData?['type'] as String? ?? info.modelType,
      tagNames: List<String>.from(modelData?['tags'] as List? ?? []),
      modelNsfw: modelData?['nsfw'] as bool? ?? false,
      modelNsfwLevel: modelData?['nsfwLevel'] as int? ?? 0,
      images: images,
      files: files,
    );

    return true;
  }

  // ---------------------------------------------------------------------------
  // Path parsing
  // ---------------------------------------------------------------------------

  /// Parse a file path into [ModelFileInfo], or `null` if the path doesn't
  /// match the expected directory structure.
  static ModelFileInfo? extractModelInfo(String filePath) {
    final normalized = p.normalize(filePath);
    final parts = normalized.split(p.separator);

    // Minimum: .../modelType/modelId/versionId/file.ext
    if (parts.length < 4) return null;

    final fileName = parts.last;
    final dot = fileName.lastIndexOf('.');
    if (dot == -1) return null;
    final ext = fileName.substring(dot).toLowerCase();

    if (!_extensions.contains(ext)) return null;

    // New layout: .../modelType/modelId/versionId/files/file.ext
    final hasFilesFolder = parts[parts.length - 2] == 'files';

    final String modelType;
    final int modelId;
    final int versionId;

    if (hasFilesFolder) {
      if (parts.length < 5) return null;
      modelType = parts[parts.length - 5];
      modelId = int.tryParse(parts[parts.length - 4]) ?? -1;
      versionId = int.tryParse(parts[parts.length - 3]) ?? -1;
    } else {
      modelType = parts[parts.length - 4];
      modelId = int.tryParse(parts[parts.length - 3]) ?? -1;
      versionId = int.tryParse(parts[parts.length - 2]) ?? -1;
    }

    if (modelId < 0 || versionId < 0) return null;

    return ModelFileInfo(
      modelType: modelType,
      modelId: modelId,
      versionId: versionId,
      filePath: normalized,
      fileName: fileName.substring(0, dot),
      fileExtension: ext,
      isNewLayout: hasFilesFolder,
    );
  }
}
