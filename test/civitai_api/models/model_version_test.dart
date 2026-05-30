import 'package:test/test.dart';

import 'package:flutter_civitai_box/civitai_api/models/model_version.dart';
import 'package:flutter_civitai_box/civitai_api/models/shared.dart';

void main() {
  group('ModelVersionEndpointData', () {
    test('fromJson with complete data (no thumbsDownCount in stats)', () {
      final json = {
        'id': 999,
        'modelId': 456,
        'name': 'v3.0 Final',
        'baseModel': 'SD 3.5',
        'baseModelType': 'Checkpoint',
        'publishedAt': '2026-01-01T00:00:00.000Z',
        'nsfwLevel': 1,
        'description': '<p>Final release</p>',
        'trainedWords': ['word1', 'word2'],
        'stats': {
          'downloadCount': 15000,
          'rating': 4.9,
          'ratingCount': 200,
          'thumbsUpCount': 1800,
          // Note: no thumbsDownCount
        },
        'files': [
          {
            'id': 200,
            'sizeKB': 4096.0,
            'name': 'final.safetensors',
            'type': 'Model',
            'downloadUrl': 'https://civitai.com/api/download/models/200',
          },
        ],
        'images': [
          {
            'url': 'https://image.civitai.com/y/width=512/99999.png',
            'nsfwLevel': 0,
            'width': 512,
            'height': 512,
            'hash': 'def456',
            'type': 'image',
          },
        ],
      };
      final data = ModelVersionEndpointData.fromJson(json);
      expect(data.id, 999);
      expect(data.modelId, 456);
      expect(data.name, 'v3.0 Final');
      expect(data.baseModel, 'SD 3.5');
      expect(data.publishedAt.year, 2026);
      expect(data.stats.downloadCount, 15000);
      expect(data.stats.rating, 4.9);
      expect(data.stats.thumbsUpCount, 1800);
      expect(data.files.length, 1);
      expect(data.images.length, 1);

      // Verify it uses ModelVersionEndpointStats (different from ModelVersionStats)
      expect(data.stats, isA<ModelVersionEndpointStats>());
    });

    test('fromJson with missing trainedWords and description', () {
      final json = {
        'id': 1,
        'modelId': 2,
        'name': 'v',
        'baseModel': 'SD 1.5',
        'publishedAt': '2025-01-01T00:00:00.000Z',
        'nsfwLevel': 0,
      };
      final data = ModelVersionEndpointData.fromJson(json);
      expect(data.trainedWords, []);
      expect(data.description, isNull);
    });
  });
}
