import 'package:test/test.dart';

import 'package:flutter_civitai_box/civitai_api/models/model_id.dart';
import 'package:flutter_civitai_box/civitai_api/models/shared.dart';

void main() {
  group('ModelByIdVersion', () {
    test('fromJson with images (no id field)', () {
      final json = {
        'id': 10,
        'index': 0,
        'name': 'v2.0',
        'baseModel': 'SDXL 1.0',
        'baseModelType': 'Checkpoint',
        'publishedAt': '2025-03-15T12:00:00.000Z',
        'availability': 'Public',
        'nsfwLevel': 2,
        'description': '<p>Detailed description</p>',
        'trainedWords': ['style1'],
        'stats': {
          'downloadCount': 5000,
          'rating': 4.8,
          'thumbsUpCount': 200,
          'thumbsDownCount': 5,
        },
        'files': [
          {
            'id': 100,
            'sizeKB': 2048.0,
            'name': 'model.safetensors',
            'type': 'Model',
            'downloadUrl': 'https://civitai.com/api/download/models/100',
            'metadata': {'fp': 'fp16', 'size': 'full', 'format': 'SafeTensor'},
          },
        ],
        'images': [
          {
            'url': 'https://image.civitai.com/x/width=1024/1743606.jpeg',
            'nsfwLevel': 1,
            'width': 1024,
            'height': 768,
            'hash': 'abc123',
            'type': 'image',
          },
        ],
      };
      final version = ModelByIdVersion.fromJson(json);
      expect(version.id, 10);
      expect(version.name, 'v2.0');
      expect(version.baseModel, 'SDXL 1.0');
      expect(version.stats.rating, 4.8);
      expect(version.stats.thumbsDownCount, 5);
      expect(version.files.length, 1);
      expect(version.files[0].name, 'model.safetensors');
      expect(version.images.length, 1);
      expect(version.images[0].url, contains('1743606'));
      // ModelById images use ModelImage (no id field)
      expect(version.images[0], isA<ModelImage>());
    });

    test('fromJson with missing optional fields', () {
      final json = {
        'id': 1,
        'index': 0,
        'name': 'v',
        'baseModel': 'SD 1.5',
        'nsfwLevel': 0,
      };
      final v = ModelByIdVersion.fromJson(json);
      expect(v.publishedAt, isNull);
      expect(v.description, isNull);
      expect(v.trainedWords, []);
    });
  });

  group('ModelById', () {
    test('fromJson with complete data', () {
      final json = {
        'id': 456,
        'name': 'Detailed Model',
        'description': 'A model with full details',
        'type': 'LORA',
        'poi': true,
        'nsfw': true,
        'nsfwLevel': 3,
        'creator': {
          'username': 'artist1',
          'modelCount': 42,
          'link': 'https://civitai.com/user/artist1',
          'image': 'https://img.example.com/avatar.png',
        },
        'stats': {
          'downloadCount': 99999,
          'favoriteCount': 5000,
          'thumbsUpCount': 8000,
          'thumbsDownCount': 200,
          'commentCount': 450,
          'ratingCount': 300,
          'rating': 4.7,
          'tippedAmountCount': 120,
        },
        'tags': ['anime', 'illustration', 'detailed'],
        'modelVersions': [
          {
            'id': 10,
            'index': 0,
            'name': 'v1.0',
            'baseModel': 'SDXL 1.0',
            'nsfwLevel': 0,
          },
          {
            'id': 11,
            'index': 1,
            'name': 'v2.0',
            'baseModel': 'SDXL 1.0',
            'nsfwLevel': 0,
          },
        ],
      };
      final model = ModelById.fromJson(json);
      expect(model.id, 456);
      expect(model.name, 'Detailed Model');
      expect(model.type, 'LORA');
      expect(model.creator?.username, 'artist1');
      expect(model.creator?.modelCount, 42);
      expect(model.stats.downloadCount, 99999);
      expect(model.stats.favoriteCount, 5000);
      expect(model.tags.length, 3);
      expect(model.modelVersions.length, 2);
      expect(model.modelVersions[1].name, 'v2.0');
    });

    test('fromJson with null creator', () {
      final json = {'id': 1, 'name': 'M', 'nsfwLevel': 0, 'modelVersions': []};
      final model = ModelById.fromJson(json);
      expect(model.creator, isNull);
    });

    test('fromJson defaults', () {
      final model = ModelById.fromJson({
        'id': 1,
        'name': 'M',
        'nsfwLevel': 0,
        'modelVersions': [],
      });
      expect(model.type, 'Other');
      expect(model.poi, false);
      expect(model.nsfw, false);
      expect(model.tags, []);
    });
  });
}
