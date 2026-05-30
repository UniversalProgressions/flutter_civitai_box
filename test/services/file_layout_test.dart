import 'package:flutter_civitai_box/services/file_layout.dart';
import 'package:test/test.dart';

void main() {
  const basePath = '/models';
  const modelType = 'Checkpoint';
  const modelId = 1595884;
  const versionId = 1805971;

  group('getModelIdPath', () {
    test('builds model directory path', () {
      final path = getModelIdPath(basePath, modelType, modelId);
      expect(path, contains('Checkpoint'));
      expect(path, contains('1595884'));
      expect(path, contains('models')); // basePath segment
    });
  });

  group('getModelVersionPath', () {
    test('builds version directory path', () {
      final path = getModelVersionPath(basePath, modelType, modelId, versionId);
      expect(path, contains('1805971'));
      // must be a child of model-id path
      final modelPath = getModelIdPath(basePath, modelType, modelId);
      expect(path, contains(modelPath));
    });
  });

  group('getFilesDir', () {
    test('appends "files" subdirectory', () {
      final path = getFilesDir(basePath, modelType, modelId, versionId);
      expect(path, endsWith('files'));
    });
  });

  group('getMediaDir', () {
    test('appends "media" subdirectory', () {
      final path = getMediaDir(basePath, modelType, modelId, versionId);
      expect(path, endsWith('media'));
    });
  });

  group('getApiInfoJsonFileName', () {
    test('formats correctly', () {
      expect(getApiInfoJsonFileName(123), '123.api-info.json');
      expect(getApiInfoJsonFileName(0), '0.api-info.json');
    });
  });

  group('getModelIdApiInfoJsonPath', () {
    test('places json inside model-id directory', () {
      final path = getModelIdApiInfoJsonPath(basePath, modelType, modelId);
      final modelDir = getModelIdPath(basePath, modelType, modelId);
      expect(path, contains(modelDir));
      expect(path, endsWith('1595884.api-info.json'));
    });
  });

  group('getModelVersionApiInfoJsonPath', () {
    test('places json inside version directory', () {
      final path = getModelVersionApiInfoJsonPath(
        basePath,
        modelType,
        modelId,
        versionId,
      );
      final versionDir = getModelVersionPath(
        basePath,
        modelType,
        modelId,
        versionId,
      );
      expect(path, contains(versionDir));
      expect(path, endsWith('1805971.api-info.json'));
    });
  });

  group('layout consistency', () {
    test('files-dir is a child of version-dir', () {
      final versionDir = getModelVersionPath(
        basePath,
        modelType,
        modelId,
        versionId,
      );
      final filesDir = getFilesDir(basePath, modelType, modelId, versionId);
      expect(filesDir, contains(versionDir));
    });

    test('media-dir is a child of version-dir', () {
      final versionDir = getModelVersionPath(
        basePath,
        modelType,
        modelId,
        versionId,
      );
      final mediaDir = getMediaDir(basePath, modelType, modelId, versionId);
      expect(mediaDir, contains(versionDir));
    });

    test('version dir is a child of model-id dir', () {
      final modelDir = getModelIdPath(basePath, modelType, modelId);
      final versionDir = getModelVersionPath(
        basePath,
        modelType,
        modelId,
        versionId,
      );
      expect(versionDir, contains(modelDir));
    });
  });
}
