import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_civitai_box/civitai_api/civitai_api.dart';
import 'package:flutter_civitai_box/db/db.dart';
import 'package:flutter_civitai_box/services/download/download_magazine_database.dart';
import 'package:flutter_civitai_box/services/download/download_magazine_item.dart';
import 'package:flutter_civitai_box/services/download/download_queue.dart';
import 'package:flutter_civitai_box/services/download/download_task.dart';
import 'package:flutter_civitai_box/services/file_layout.dart';
import 'package:flutter_civitai_box/services/logger.dart';
import 'package:flutter_civitai_box/services/model_refresh_bus.dart';
import 'package:flutter_civitai_box/settings/settings.dart';

export 'download_magazine_item.dart' show LoadResult, LoadError, LoadErrorType;

/// Load a model version into the download magazine.
Future<LoadResult> load({
  required int modelVersionId,
  required CivitaiApiClient api,
}) async {
  if (modelVersionId <= 0) {
    return LoadResult.error(
      const LoadError(
        type: LoadErrorType.invalidId,
        message: 'Model version ID must be a positive integer',
      ),
    );
  }

  const magazineDb = DownloadMagazineDatabase();
  final existing = await magazineDb.findByModelVersionId(modelVersionId);
  if (existing != null) {
    return LoadResult.error(
      LoadError(
        type: LoadErrorType.alreadyInMagazine,
        message: 'Version $modelVersionId is already in the magazine',
      ),
    );
  }

  // Fetch version
  ModelVersionEndpointData version;
  try {
    version = await api.modelVersions.getById(modelVersionId);
  } on CivitaiNetworkException catch (e) {
    return LoadResult.error(
      LoadError(type: LoadErrorType.networkError, message: e.message),
    );
  } on CivitaiApiException catch (e) {
    return LoadResult.error(
      LoadError(
        type: LoadErrorType.apiError,
        message: 'API error (${e.statusCode}): ${e.message}',
      ),
    );
  } catch (e) {
    return LoadResult.error(
      LoadError(
        type: LoadErrorType.apiError,
        message: 'Failed to parse API response',
        detail: e.toString(),
      ),
    );
  }

  if (version.files.isEmpty && version.images.isEmpty) {
    return LoadResult.error(
      LoadError(
        type: LoadErrorType.validationError,
        message: 'Version $modelVersionId has no downloadable files',
      ),
    );
  }

  final modelId = version.modelId;
  final versionJson = jsonEncode((version as dynamic).toJson());

  // Fetch model
  ModelById model;
  try {
    model = await api.models.getById(modelId);
  } on CivitaiNetworkException catch (e) {
    return LoadResult.error(
      LoadError(type: LoadErrorType.networkError, message: e.message),
    );
  } on CivitaiApiException catch (e) {
    return LoadResult.error(
      LoadError(
        type: LoadErrorType.apiError,
        message: 'API error (${e.statusCode}): ${e.message}',
      ),
    );
  } catch (e) {
    return LoadResult.error(
      LoadError(
        type: LoadErrorType.apiError,
        message: 'Failed to parse model response',
        detail: e.toString(),
      ),
    );
  }

  if (model.name.isEmpty) {
    return LoadResult.error(
      const LoadError(
        type: LoadErrorType.validationError,
        message: 'Invalid API response: model name is empty',
      ),
    );
  }

  final modelJson = jsonEncode((model as dynamic).toJson());
  final fileCount = version.files.length + version.images.length;
  final totalSizeKb = version.files.fold<double>(0, (sum, f) => sum + f.sizeKB);

  final item = MagazineItem(
    id: 0,
    modelVersionId: modelVersionId,
    modelId: modelId,
    modelName: model.name,
    versionName: version.name,
    baseModel: version.baseModel,
    modelType: model.type,
    fileCount: fileCount,
    totalSizeKb: totalSizeKb,
    modelJson: modelJson,
    versionJson: versionJson,
    status: MagazineItemStatus.pending,
    loadedAt: DateTime.now(),
  );

  try {
    final saved = await magazineDb.insert(item);
    return LoadResult.ok(saved);
  } catch (e) {
    return LoadResult.error(
      LoadError(
        type: LoadErrorType.validationError,
        message: 'Failed to save to magazine',
        detail: e.toString(),
      ),
    );
  }
}

// =============================================================================
// Fire
// =============================================================================

/// Fire the magazine — process rounds one at a time.
///
/// Each round is processed sequentially. On success the round is deleted.
/// On failure the round is retried up to 3 times, then the magazine jams.
///
/// [downloadRound] is called for each round. Return `true` for success,
/// `false` for failure. In production this performs the actual download;
/// in tests it can be mocked.
Stream<FireEvent> fire({
  required DownloadMagazineDatabase magazineDb,
  required Future<bool> Function(MagazineItem item) downloadRound,
}) async* {
  final pending = await magazineDb.loadPending();
  if (pending.isEmpty) {
    yield const FireEvent.done(
      FireSummary(completed: 0, skipped: 0, failed: 0),
    );
    return;
  }

  var completed = 0;
  bool jammed = false;

  for (final round in pending) {
    // Check for skipped/failed rounds before processing
    if (jammed) break;

    yield FireEvent.roundStarted(round);
    await magazineDb.update(
      round.copyWith(
        status: MagazineItemStatus.firing,
        firedAt: DateTime.now(),
      ),
    );

    var success = false;
    var retries = round.retryCount;

    while (retries < 3 && !success) {
      try {
        success = await downloadRound(round);
      } catch (_) {
        success = false;
      }

      if (!success && retries < 2) {
        // Retry
        retries++;
        await magazineDb.update(
          round.copyWith(
            status: MagazineItemStatus.pending,
            retryCount: retries,
            errorMessage: 'Download failed (attempt ${retries + 1}/3)',
          ),
        );
        yield FireEvent.retrying(
          round,
          retries + 1,
          'Download failed (attempt ${retries + 1}/3)',
        );
      } else if (!success) {
        // Jam
        retries = 3;
        await magazineDb.update(
          round.copyWith(
            status: MagazineItemStatus.failed,
            retryCount: 3,
            errorMessage: 'Failed after 3 attempts',
          ),
        );
        yield FireEvent.jammed(round);
        jammed = true;
      } else {
        // Success — delete the round
        await magazineDb.delete(round.id);
        completed++;
        yield FireEvent.roundCompleted(round.modelVersionId, round.modelName);
      }
    }
  }

  // Re-count final state
  final allRounds = await magazineDb.loadAll();
  yield FireEvent.done(
    FireSummary(
      completed: completed,
      skipped: allRounds
          .where((r) => r.status == MagazineItemStatus.skipped)
          .length,
      failed: allRounds
          .where((r) => r.status == MagazineItemStatus.failed)
          .length,
    ),
  );
}

// =============================================================================
// Production Wiring
// =============================================================================

/// Production entry point — fire the magazine with real DownloadQueue.
///
/// Unlike [fire], this wires up the actual download infrastructure:
/// URL resolution, DownloadQueue enqueue, file writes, DB upserts,
/// and ModelRefreshBus notifications.
Stream<FireEvent> fireProduction({
  required DownloadMagazineDatabase magazineDb,
  required CivitaiApiClient api,
}) async* {
  yield* fire(
    magazineDb: magazineDb,
    downloadRound: (item) => _productionDownloadRound(item, api),
  );
}

/// The real download step for a single magazine round.
///
/// Returns `true` if all files downloaded successfully, `false` otherwise.
Future<bool> _productionDownloadRound(
  MagazineItem item,
  CivitaiApiClient api,
) async {
  try {
    // 1. Parse JSON blobs from magazine
    final versionMap = jsonDecode(item.versionJson) as Map<String, dynamic>;
    final modelMap = jsonDecode(item.modelJson) as Map<String, dynamic>;

    // 2. Get settings
    final svc = await SettingsService.getInstance();
    final basePath = svc.settingsOrNull?.basePath ?? '';
    final modelType = item.modelType ?? 'Other';
    final modelId = item.modelId;
    final versionId = item.modelVersionId;

    // 3. Build batch ID
    final batchId =
        'mag-${modelId}-${versionId}-${DateTime.now().millisecondsSinceEpoch}';

    // 4. Resolve model file URLs
    final files = (versionMap['files'] as List?) ?? [];
    final modelTasks = <DownloadTask>[];
    for (final f in files) {
      if (f['type'] != 'Model') continue;
      final rawUrl = f['downloadUrl'] as String;
      final resolvedUrl = await _resolveUrl(rawUrl, api);
      final filesDir = getFilesDir(basePath, modelType, modelId, versionId);
      modelTasks.add(
        DownloadTask(
          id: '$batchId-f-${f['id']}',
          batchId: batchId,
          modelId: modelId,
          modelVersionId: versionId,
          fileName: f['name'] as String,
          fileSizeKb: (f['sizeKB'] as num?)?.toDouble() ?? 0,
          downloadUrl: resolvedUrl,
          targetPath: '$filesDir/${f['name']}',
          fileType: DownloadFileType.model,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
    }

    // 5. Resolve media URLs
    final images = (versionMap['images'] as List?) ?? [];
    final mediaTasks = <DownloadTask>[];
    for (final img in images) {
      if ((img['type'] ?? 'image') != 'image') continue;
      final rawUrl = img['url'] as String;
      final resolvedUrl = await _resolveUrl(rawUrl, api);
      final imageId = extractIdFromImageUrl(rawUrl) ?? 0;
      final ext = _extFromUrl(rawUrl);
      final mediaDir = getMediaDir(basePath, modelType, modelId, versionId);
      mediaTasks.add(
        DownloadTask(
          id: '$batchId-m-$imageId',
          batchId: batchId,
          modelId: modelId,
          modelVersionId: versionId,
          fileName: '$imageId$ext',
          fileSizeKb: 0,
          downloadUrl: resolvedUrl,
          targetPath: '$mediaDir/$imageId$ext',
          fileType: DownloadFileType.media,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
    }

    // 6. No apiJson tasks — JSON files written after success
    final allTasks = <DownloadTask>[...modelTasks, ...mediaTasks];
    if (allTasks.isEmpty) {
      logger.warning('No downloadable files for version $versionId');
      // Still write JSON files and mark success
      await _writeApiJsonFiles(
        basePath,
        modelType,
        modelId,
        versionId,
        modelMap,
        versionMap,
      );
      await _upsertToDb(modelMap, versionMap);
      ModelRefreshBus.instance.notify();
      return true;
    }

    // 7. Enqueue to DownloadQueue
    await DownloadQueue.instance.enqueueBatch(
      batchId: batchId,
      apiJsonTasks: const [],
      modelTasks: modelTasks,
      mediaTasks: mediaTasks,
    );

    // 8. Wait for batch completion
    final success = await _waitForBatch(batchId);
    if (!success) return false;

    // 9. Write API JSON files to disk (completion markers)
    await _writeApiJsonFiles(
      basePath,
      modelType,
      modelId,
      versionId,
      modelMap,
      versionMap,
    );

    // 10. Upsert to local DB
    await _upsertToDb(modelMap, versionMap);

    // 11. Notify
    ModelRefreshBus.instance.notify();

    return true;
  } catch (e, st) {
    logger.error('Production download round failed', e, st);
    return false;
  }
}

// ---------------------------------------------------------------------------
// Production helpers
// ---------------------------------------------------------------------------

/// Resolve a download URL through CivitAI's redirect chain.
Future<String> _resolveUrl(String url, CivitaiApiClient api) async {
  try {
    return await api.modelVersions.resolveFileDownloadUrl(url);
  } catch (_) {
    return url; // Fall back to raw URL
  }
}

/// Extract file extension from a URL.
String _extFromUrl(String url) {
  final uri = Uri.tryParse(url);
  final path = uri?.path ?? url;
  final dotIdx = path.lastIndexOf('.');
  if (dotIdx == -1) return '.jpeg';
  final ext = path.substring(dotIdx);
  final qIdx = ext.indexOf('?');
  return qIdx == -1 ? ext : ext.substring(0, qIdx);
}

/// Wait for all tasks in a batch to complete (or fail).
Future<bool> _waitForBatch(String batchId) async {
  final completer = Completer<bool>();
  StreamSubscription<DownloadQueueState>? sub;

  sub = DownloadQueue.instance.stateStream.listen((state) {
    final batch = state.batches[batchId];
    if (batch == null) return; // Not yet loaded

    final allDone = batch.every(
      (t) => t.status == DownloadTaskStatus.completed,
    );
    final anyFailed = batch.any(
      (t) =>
          t.status == DownloadTaskStatus.failed ||
          t.status == DownloadTaskStatus.cancelled,
    );

    if (allDone) {
      sub?.cancel();
      completer.complete(true);
    } else if (anyFailed) {
      sub?.cancel();
      completer.complete(false);
    }
  });

  return completer.future;
}

/// Write API JSON files to disk.
Future<void> _writeApiJsonFiles(
  String basePath,
  String modelType,
  int modelId,
  int versionId,
  Map<String, dynamic> modelJson,
  Map<String, dynamic> versionJson,
) async {
  final encoder = const JsonEncoder.withIndent('  ');

  // Model JSON
  final modelPath = getModelIdApiInfoJsonPath(basePath, modelType, modelId);
  final modelFile = File(modelPath);
  await modelFile.parent.create(recursive: true);
  await modelFile.writeAsString(encoder.convert(modelJson));

  // Version JSON
  final versionPath = getModelVersionApiInfoJsonPath(
    basePath,
    modelType,
    modelId,
    versionId,
  );
  final versionFile = File(versionPath);
  await versionFile.parent.create(recursive: true);
  await versionFile.writeAsString(encoder.convert(versionJson));
}

/// Upsert model and version to local SQLite database.
Future<void> _upsertToDb(
  Map<String, dynamic> modelMap,
  Map<String, dynamic> versionMap,
) async {
  // Upsert version (which cascades to model)
  const versionRepo = ModelVersionRepository();

  final images = ((versionMap['images'] as List?) ?? []).map((img) {
    final imageId = extractIdFromImageUrl(img['url'] as String) ?? 0;
    return {
      'id': imageId,
      'url': img['url'],
      'nsfwLevel': img['nsfwLevel'],
      'width': img['width'],
      'height': img['height'],
      'hash': img['hash'] ?? '',
      'type': img['type'],
    };
  }).toList();

  final files = ((versionMap['files'] as List?) ?? []).map((f) {
    return {
      'id': f['id'],
      'sizeKB': f['sizeKB'],
      'name': f['name'],
      'type': f['type'],
      'downloadUrl': f['downloadUrl'],
    };
  }).toList();

  final creatorJson = modelMap['creator'] as Map<String, dynamic>?;
  final tagNames = (modelMap['tags'] as List?)?.cast<String>() ?? [];

  await versionRepo.upsertVersion(
    id: versionMap['id'] as int,
    modelId: versionMap['modelId'] as int,
    name: versionMap['name'] as String,
    baseModelName: versionMap['baseModel'] as String,
    baseModelTypeName: versionMap['baseModelType'] as String?,
    nsfwLevel: versionMap['nsfwLevel'] as int? ?? 0,
    versionJson: versionMap,
    modelJson: modelMap,
    modelName: modelMap['name'] as String? ?? '',
    creatorJson: creatorJson,
    modelTypeName: modelMap['type'] as String? ?? 'Other',
    tagNames: tagNames,
    modelNsfw: modelMap['nsfw'] as bool? ?? false,
    modelNsfwLevel: modelMap['nsfwLevel'] as int? ?? 0,
    images: images,
    files: files,
  );
}
