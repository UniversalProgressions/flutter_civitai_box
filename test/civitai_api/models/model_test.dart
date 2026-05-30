import 'package:test/test.dart';

import 'package:flutter_civitai_box/civitai_api/models/model.dart';

void main() {
  group('ModelVersion', () {
    test('fromJson parses basic fields', () {
      final json = {
        'id': 1,
        'index': 0,
        'name': 'v1.0',
        'baseModel': 'SD 1.5',
        'baseModelType': 'Checkpoint',
        'publishedAt': '2025-06-01T00:00:00.000Z',
        'availability': 'Public',
        'nsfwLevel': 0,
        'description': 'A test version',
        'trainedWords': ['cat', 'dog'],
        'stats': {
          'downloadCount': 100,
          'thumbsUpCount': 10,
          'thumbsDownCount': 1,
        },
        'files': [],
        'images': [],
      };
      final version = ModelVersion.fromJson(json);
      expect(version.id, 1);
      expect(version.index, 0);
      expect(version.name, 'v1.0');
      expect(version.baseModel, 'SD 1.5');
      expect(version.publishedAt, isNotNull);
      expect(version.availability, 'Public');
      expect(version.nsfwLevel, 0);
      expect(version.trainedWords, ['cat', 'dog']);
      expect(version.stats.downloadCount, 100);
    });

    test('fromJson with null publishedAt', () {
      final json = _minimalVersionJson();
      json['publishedAt'] = null;
      final v = ModelVersion.fromJson(json);
      expect(v.publishedAt, isNull);
    });

    test('fromJson defaults', () {
      final v = ModelVersion.fromJson({
        'id': 1,
        'index': 0,
        'name': 'v',
        'baseModel': 'SD 1.5',
        'nsfwLevel': 0,
      });
      expect(v.availability, 'Public');
      expect(v.trainedWords, []);
      expect(v.files, []);
      expect(v.images, []);
    });
  });

  group('Model', () {
    test('fromJson with versions', () {
      final json = {
        'id': 123,
        'name': 'Cool Model',
        'description': 'A very cool model',
        'type': 'Checkpoint',
        'poi': false,
        'nsfw': false,
        'nsfwLevel': 1,
        'creator': {
          'username': 'creator1',
          'image': 'https://img.example.com/u.jpg',
        },
        'stats': {
          'downloadCount': 10000,
          'thumbsUpCount': 500,
          'commentCount': 30,
          'tippedAmountCount': 5,
        },
        'tags': ['fantasy', 'portrait'],
        'modelVersions': [
          {
            'id': 1,
            'index': 0,
            'name': 'v1',
            'baseModel': 'SD 1.5',
            'nsfwLevel': 0,
          },
        ],
      };
      final model = Model.fromJson(json);
      expect(model.id, 123);
      expect(model.name, 'Cool Model');
      expect(model.description, 'A very cool model');
      expect(model.type, 'Checkpoint');
      expect(model.creator?.username, 'creator1');
      expect(model.tags, ['fantasy', 'portrait']);
      expect(model.modelVersions.length, 1);
      expect(model.modelVersions[0].name, 'v1');
    });

    test('fromJson with null creator (deleted account)', () {
      final json = {
        'id': 1,
        'name': 'Orphan Model',
        'nsfwLevel': 0,
        'modelVersions': [],
      };
      final model = Model.fromJson(json);
      expect(model.creator, isNull);
    });

    test('fromJson defaults', () {
      final model = Model.fromJson({
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

    test('copyWith', () {
      final m = Model(id: 1, name: 'old', nsfwLevel: 0, modelVersions: []);
      expect(m.copyWith(name: 'new').name, 'new');
    });
  });

  group('ModelsResponse', () {
    test('fromJson with items', () {
      final json = {
        'items': [
          {'id': 1, 'name': 'M1', 'nsfwLevel': 0, 'modelVersions': []},
          {'id': 2, 'name': 'M2', 'nsfwLevel': 1, 'modelVersions': []},
        ],
        'metadata': {'totalItems': 200, 'currentPage': 1, 'pageSize': 100},
      };
      final response = ModelsResponse.fromJson(json);
      expect(response.items.length, 2);
      expect(response.items[0].name, 'M1');
      expect(response.items[1].id, 2);
      expect(response.metadata.totalItems, 200);
    });
  });
}

Map<String, dynamic> _minimalVersionJson() => {
  'id': 1,
  'index': 0,
  'name': 'v',
  'baseModel': 'SD 1.5',
  'nsfwLevel': 0,
};
