import 'dart:convert';
import 'dart:io';

import 'package:flutter_civitai_box/services/file_layout.dart';
import 'package:test/test.dart';

/// Mirrors the logic in DownloadPage._writeModelJson / _writeVersionJson.
Future<void> writeModelJson(
  String basePath,
  String modelType,
  int modelId,
  Map<String, dynamic> json,
) async {
  final filePath = getModelIdApiInfoJsonPath(basePath, modelType, modelId);
  final file = File(filePath);
  await file.parent.create(recursive: true);
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
}

Future<void> writeVersionJson(
  String basePath,
  String modelType,
  int modelId,
  int versionId,
  Map<String, dynamic> json,
) async {
  final filePath = getModelVersionApiInfoJsonPath(
    basePath,
    modelType,
    modelId,
    versionId,
  );
  final file = File(filePath);
  await file.parent.create(recursive: true);
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
}

void main() {
  late Directory tmpDir;

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('civitai_json_test_');
  });

  tearDown(() {
    if (tmpDir.existsSync()) tmpDir.deleteSync(recursive: true);
  });

  // =========================================================================
  // Model JSON
  // =========================================================================
  group('Model-level API JSON', () {
    test('writes to correct path', () async {
      final modelJson = {
        'id': 12345,
        'name': 'Test Model',
        'type': 'Checkpoint',
        'nsfw': false,
        'modelVersions': [
          {'id': 1, 'name': 'v1'},
          {'id': 2, 'name': 'v2'},
        ],
      };

      await writeModelJson(tmpDir.path, 'Checkpoint', 12345, modelJson);

      final expectedPath = getModelIdApiInfoJsonPath(
        tmpDir.path,
        'Checkpoint',
        12345,
      );
      expect(File(expectedPath).existsSync(), isTrue);

      final content = File(expectedPath).readAsStringSync();
      final parsed = jsonDecode(content) as Map<String, dynamic>;
      expect(parsed['id'], equals(12345));
      expect(parsed['name'], equals('Test Model'));
    });

    test('retains modelVersions field', () async {
      final modelVersions = [
        {'id': 1, 'name': 'v1', 'baseModel': 'SD 1.5'},
        {'id': 2, 'name': 'v2', 'baseModel': 'SDXL'},
        {'id': 3, 'name': 'v3', 'baseModel': 'SD 1.5'},
      ];

      final modelJson = {
        'id': 999,
        'name': 'Multi Version Model',
        'type': 'Checkpoint',
        'modelVersions': modelVersions,
      };

      await writeModelJson(tmpDir.path, 'Checkpoint', 999, modelJson);

      final path = getModelIdApiInfoJsonPath(tmpDir.path, 'Checkpoint', 999);
      final parsed =
          jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

      final savedVersions = parsed['modelVersions'] as List;
      expect(savedVersions.length, equals(3));
      expect((savedVersions[0] as Map)['baseModel'], equals('SD 1.5'));
    });

    test('creates parent directories automatically', () async {
      final modelJson = {'id': 1, 'name': 'Test', 'type': 'Checkpoint'};

      // Sub-path that doesn't exist yet
      await writeModelJson(tmpDir.path, 'Checkpoint', 1, modelJson);

      final path = getModelIdApiInfoJsonPath(tmpDir.path, 'Checkpoint', 1);
      expect(Directory(path).parent.existsSync(), isTrue);
      expect(File(path).existsSync(), isTrue);
    });

    test('model JSON is valid and readable by Scanner logic', () async {
      final modelJson = {
        'id': 100,
        'name': 'Readable Test',
        'type': 'LoRA',
        'nsfw': false,
        'nsfwLevel': 0,
        'creator': {'username': 'test_creator', 'image': 'http://img.url'},
        'tags': ['tag1', 'tag2'],
        'modelVersions': [
          {'id': 10, 'name': 'v1', 'baseModel': 'SD 1.5'},
        ],
      };

      await writeModelJson(tmpDir.path, 'LoRA', 100, modelJson);

      final path = getModelIdApiInfoJsonPath(tmpDir.path, 'LoRA', 100);
      final parsed =
          jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

      // Verify all keys survived round-trip
      expect(parsed['id'], equals(100));
      expect(parsed['type'], equals('LoRA'));
      expect(parsed['creator'], isA<Map>());
      expect((parsed['creator'] as Map)['username'], equals('test_creator'));
      expect(parsed['tags'], equals(['tag1', 'tag2']));
      expect(parsed['modelVersions'], isA<List>());
    });
  });

  // =========================================================================
  // Version JSON
  // =========================================================================
  group('Version-level API JSON', () {
    test('writes to correct path', () async {
      final versionJson = {
        'id': 456,
        'modelId': 12345,
        'name': 'v1-fp16',
        'baseModel': 'SDXL',
        'files': [
          {
            'name': 'model.safetensors',
            'sizeKB': 2000000.0,
            'hashes': {'SHA256': 'abc123'},
          },
        ],
        'images': [
          {'url': 'http://img/1.jpeg', 'type': 'image', 'nsfwLevel': 1},
        ],
      };

      await writeVersionJson(
        tmpDir.path,
        'Checkpoint',
        12345,
        456,
        versionJson,
      );

      final expectedPath = getModelVersionApiInfoJsonPath(
        tmpDir.path,
        'Checkpoint',
        12345,
        456,
      );
      expect(File(expectedPath).existsSync(), isTrue);

      final parsed =
          jsonDecode(File(expectedPath).readAsStringSync())
              as Map<String, dynamic>;
      expect(parsed['id'], equals(456));
      expect(parsed['name'], equals('v1-fp16'));
    });

    test('retains files and images arrays', () async {
      final versionJson = {
        'id': 789,
        'modelId': 1,
        'name': 'v3',
        'baseModel': 'Flux',
        'files': [
          {'name': 'a.safetensors', 'sizeKB': 1000.0, 'hashes': {}},
          {'name': 'b.safetensors', 'sizeKB': 2000.0, 'hashes': {}},
        ],
        'images': [
          {'url': 'http://x/1.jpeg', 'type': 'image'},
          {'url': 'http://x/2.jpeg', 'type': 'image'},
          {'url': 'http://x/3.jpeg', 'type': 'image'},
        ],
      };

      await writeVersionJson(tmpDir.path, 'Checkpoint', 1, 789, versionJson);

      final path = getModelVersionApiInfoJsonPath(
        tmpDir.path,
        'Checkpoint',
        1,
        789,
      );
      final parsed =
          jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

      final files = parsed['files'] as List;
      expect(files.length, equals(2));

      final images = parsed['images'] as List;
      expect(images.length, equals(3));
    });

    test('hash values survive round-trip exactly', () async {
      final expectedSha256 =
          '260F2989F160C67B09FD68482D1CC45DE61A33EEC5D2FA6FCD6CF7E09BBA7D47';
      final expectedBlake3 =
          '253BD9C3037584A20AD46C833E9BC90A1F8F7EA031FD81BF1E8392DBC9C45F3E';

      final versionJson = {
        'id': 999,
        'modelId': 1,
        'name': 'hash-test',
        'baseModel': 'SD 1.5',
        'files': [
          {
            'name': 'model.safetensors',
            'sizeKB': 73888.6953125,
            'hashes': {
              'SHA256': expectedSha256,
              'BLAKE3': expectedBlake3,
              'CRC32': '93FFD3FC',
            },
          },
        ],
      };

      await writeVersionJson(tmpDir.path, 'Checkpoint', 1, 999, versionJson);

      final path = getModelVersionApiInfoJsonPath(
        tmpDir.path,
        'Checkpoint',
        1,
        999,
      );
      final parsed =
          jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

      final hashes = ((parsed['files'] as List)[0] as Map)['hashes'] as Map;
      expect(hashes['SHA256'], equals(expectedSha256));
      expect(hashes['BLAKE3'], equals(expectedBlake3));
    });
  });

  // =========================================================================
  // Edge cases
  // =========================================================================
  group('Edge cases', () {
    test('overwrites existing JSON file', () async {
      final json1 = {'id': 1, 'name': 'First'};
      final json2 = {'id': 1, 'name': 'Second', 'updated': true};

      await writeModelJson(tmpDir.path, 'Checkpoint', 1, json1);
      await writeModelJson(tmpDir.path, 'Checkpoint', 1, json2);

      final path = getModelIdApiInfoJsonPath(tmpDir.path, 'Checkpoint', 1);
      final parsed =
          jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
      expect(parsed['name'], equals('Second'));
      expect(parsed['updated'], isTrue);
    });

    test('model type with space creates valid path', () async {
      final json = {'id': 5, 'name': 'Test', 'type': 'Textual Inversion'};

      await writeModelJson(tmpDir.path, 'Textual Inversion', 5, json);

      final path = getModelIdApiInfoJsonPath(
        tmpDir.path,
        'Textual Inversion',
        5,
      );
      expect(File(path).existsSync(), isTrue);
    });

    test('multiple versions for same model write to distinct paths', () async {
      for (var vid = 1; vid <= 5; vid++) {
        final vJson = {'id': vid, 'modelId': 42, 'name': 'v$vid'};
        await writeVersionJson(tmpDir.path, 'Checkpoint', 42, vid, vJson);
      }

      for (var vid = 1; vid <= 5; vid++) {
        final path = getModelVersionApiInfoJsonPath(
          tmpDir.path,
          'Checkpoint',
          42,
          vid,
        );
        expect(File(path).existsSync(), isTrue);
        final parsed =
            jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
        expect(parsed['id'], equals(vid));
      }
    });
  });
}
