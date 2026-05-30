import 'dart:convert';
import 'dart:io';

import 'package:flutter_civitai_box/db/db.dart';
import 'package:flutter_civitai_box/services/file_layout.dart';
import 'package:flutter_civitai_box/services/scanner/scan_result.dart';
import 'package:flutter_civitai_box/services/scanner/scanner_service.dart';
import 'package:flutter_civitai_box/settings/settings.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

/// Reads a JSON fixture from `test/data/`.
Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/data/$name').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tmpDir;

  setUp(() async {
    tmpDir = Directory.systemTemp.createTempSync('civitai_scanner_test_');
    await CivitaiDatabase.initForTest(':memory:');
  });

  tearDown(() async {
    await CivitaiDatabase.instance.then((db) => db.close());
    if (tmpDir.existsSync()) tmpDir.deleteSync(recursive: true);
  });

  /// Creates the full directory structure and files for a test model version.
  Future<void> createFixtureModel({
    required String basePath,
    required String modelType,
    required int modelId,
    required Map<String, dynamic> modelJson,
    required int versionId,
    required Map<String, dynamic> versionJson,
    String modelFileName = 'model.safetensors',
  }) async {
    final filesDir = getFilesDir(basePath, modelType, modelId, versionId);
    await Directory(filesDir).create(recursive: true);

    // Dummy model file
    await File(p.join(filesDir, modelFileName)).writeAsString('fake weights');

    // Version API JSON
    final versionJsonPath = getModelVersionApiInfoJsonPath(
      basePath,
      modelType,
      modelId,
      versionId,
    );
    await File(versionJsonPath).writeAsString(jsonEncode(versionJson));

    // Model API JSON
    final modelJsonDir = getModelIdPath(basePath, modelType, modelId);
    await Directory(modelJsonDir).create(recursive: true);
    final modelJsonPath = getModelIdApiInfoJsonPath(
      basePath,
      modelType,
      modelId,
    );
    await File(modelJsonPath).writeAsString(jsonEncode(modelJson));
  }

  // ===========================================================================
  // extractModelInfo
  // ===========================================================================
  group('extractModelInfo', () {
    test('parses new layout path', () {
      final info = ScannerService.extractModelInfo(
        '/models/Checkpoint/1595884/1805971/files/model.safetensors',
      );
      expect(info, isNotNull);
      expect(info!.modelType, 'Checkpoint');
      expect(info.modelId, 1595884);
      expect(info.versionId, 1805971);
      expect(info.isNewLayout, true);
      expect(info.fileExtension, '.safetensors');
    });

    test('parses old layout path (no "files" subdir)', () {
      final info = ScannerService.extractModelInfo(
        '/models/LORA/123/456/model.ckpt',
      );
      expect(info, isNotNull);
      expect(info!.modelType, 'LORA');
      expect(info.modelId, 123);
      expect(info.versionId, 456);
      expect(info.isNewLayout, false);
    });

    test('rejects unsupported extension', () {
      expect(
        ScannerService.extractModelInfo('/m/Checkpoint/1/2/files/readme.txt'),
        isNull,
      );
    });

    test('rejects too-short path', () {
      expect(ScannerService.extractModelInfo('model.safetensors'), isNull);
    });

    test('rejects non-numeric ids', () {
      expect(
        ScannerService.extractModelInfo('/m/Checkpoint/abc/def/files/x.ckpt'),
        isNull,
      );
    });
  });

  // ===========================================================================
  // Full scan
  // ===========================================================================
  group('scan()', () {
    test('scans a single model version and upserts into DB', () async {
      final basePath = tmpDir.path;

      // 1) Set up settings
      SharedPreferences.setMockInitialValues({});
      final settingsSvc = await SettingsService.getInstance();
      settingsSvc.updateSettings({
        'basePath': basePath,
        'civitai_api_token': 'tok',
        'gopeed_api_host': 'http://localhost:8080',
      });

      // 2) Create fixture files on disk using real API data
      final versionJson = _fixture('modelVersion_endpoint_response.json');
      final modelData = versionJson['model'] as Map<String, dynamic>;
      final modelJson = {
        'id': versionJson['modelId'],
        ...modelData,
        'modelVersions': [versionJson],
      };

      await createFixtureModel(
        basePath: basePath,
        modelType: modelData['type'] as String,
        modelId: versionJson['modelId'] as int,
        modelJson: modelJson,
        versionId: versionJson['id'] as int,
        versionJson: versionJson,
        modelFileName: 'hyphoriaIlluNAI_v001.safetensors',
      );

      // 3) Run scan
      const scanner = ScannerService();
      final events = await scanner.scan().toList();

      // Last event should be ScanResult
      final result = events.last as ScanResult;
      expect(result.filesFound, 1);
      expect(result.upserted, 1);
      expect(result.skipped, 0);
      expect(result.errors, 0);

      // 4) Verify DB content
      const modelDao = ModelDao();
      final model = await modelDao.getById(1595884);
      expect(model, isNotNull);
      expect(model!['name'], 'Hyphoria [Illu & NAI]');

      const versionDao = ModelVersionDao();
      final version = await versionDao.getById(1805971);
      expect(version, isNotNull);
      expect(version!['name'], 'v0.01');

      const imageDao = ModelVersionImageDao();
      final images = await imageDao.getByModelVersion(1805971);
      expect(images.length, 10);

      const fileDao = ModelVersionFileDao();
      final files = await fileDao.getByModelVersion(1805971);
      expect(files.length, 1);
    });

    test('skips version when api-info.json is missing', () async {
      final basePath = tmpDir.path;

      SharedPreferences.setMockInitialValues({});
      final settingsSvc = await SettingsService.getInstance();
      settingsSvc.updateSettings({
        'basePath': basePath,
        'civitai_api_token': 'tok',
        'gopeed_api_host': 'http://localhost:8080',
      });

      // Create files dir with model file but NO json
      final filesDir = getFilesDir(basePath, 'Checkpoint', 999, 888);
      await Directory(filesDir).create(recursive: true);
      await File(p.join(filesDir, 'model.safetensors')).writeAsString('data');

      const scanner = ScannerService();
      final events = await scanner.scan().toList();
      final result = events.last as ScanResult;

      expect(result.filesFound, 1);
      expect(result.upserted, 0);
      expect(result.skipped, 1);
    });

    test('deduplicates multiple files from the same version', () async {
      final basePath = tmpDir.path;

      SharedPreferences.setMockInitialValues({});
      final settingsSvc = await SettingsService.getInstance();
      settingsSvc.updateSettings({
        'basePath': basePath,
        'civitai_api_token': 'tok',
        'gopeed_api_host': 'http://localhost:8080',
      });

      final versionJson = _fixture('modelVersion_endpoint_response.json');
      final modelData = versionJson['model'] as Map<String, dynamic>;
      final modelJson = {
        'id': versionJson['modelId'],
        ...modelData,
        'modelVersions': [versionJson],
      };

      final versionDir = getFilesDir(
        basePath,
        modelData['type'] as String,
        versionJson['modelId'] as int,
        versionJson['id'] as int,
      );
      await Directory(versionDir).create(recursive: true);

      // Two model files in the same version
      await File(p.join(versionDir, 'model.safetensors')).writeAsString('a');
      await File(p.join(versionDir, 'model.ckpt')).writeAsString('b');

      // Write the JSON
      final jsonPath = getModelVersionApiInfoJsonPath(
        basePath,
        modelData['type'] as String,
        versionJson['modelId'] as int,
        versionJson['id'] as int,
      );
      await File(jsonPath).writeAsString(jsonEncode(versionJson));
      final modelIdPath = getModelIdApiInfoJsonPath(
        basePath,
        modelData['type'] as String,
        versionJson['modelId'] as int,
      );
      await File(modelIdPath).parent.create(recursive: true);
      await File(modelIdPath).writeAsString(jsonEncode(modelJson));

      const scanner = ScannerService();
      final events = await scanner.scan().toList();
      final result = events.last as ScanResult;

      // 2 files found but only 1 version → upserted=1
      expect(result.filesFound, 1); // deduplicated
      expect(result.upserted, 1);
    });

    test('emits progress events', () async {
      final basePath = tmpDir.path;

      SharedPreferences.setMockInitialValues({});
      final settingsSvc = await SettingsService.getInstance();
      settingsSvc.updateSettings({
        'basePath': basePath,
        'civitai_api_token': 'tok',
        'gopeed_api_host': 'http://localhost:8080',
      });

      final versionJson = _fixture('modelVersion_endpoint_response.json');
      final modelData = versionJson['model'] as Map<String, dynamic>;
      final modelJson = {
        'id': versionJson['modelId'],
        ...modelData,
        'modelVersions': [versionJson],
      };

      await createFixtureModel(
        basePath: basePath,
        modelType: modelData['type'] as String,
        modelId: versionJson['modelId'] as int,
        modelJson: modelJson,
        versionId: versionJson['id'] as int,
        versionJson: versionJson,
      );

      const scanner = ScannerService();
      final events = await scanner.scan().toList();

      // At least 2 progress events + 1 result
      final progressEvents = events.whereType<ScanProgress>().toList();
      expect(progressEvents.length, greaterThanOrEqualTo(2));
      expect(progressEvents.first.filesFound, 1);
      expect(progressEvents.first.filesProcessed, 0);

      final result = events.whereType<ScanResult>().single;
      expect(result.duration.inMilliseconds, greaterThan(0));
    });
  });
}
