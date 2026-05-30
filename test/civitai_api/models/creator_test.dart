import 'package:test/test.dart';

import 'package:flutter_civitai_box/civitai_api/models/creator.dart';
import 'package:flutter_civitai_box/civitai_api/models/shared.dart';

void main() {
  group('Creator', () {
    test('fromJson with all fields', () {
      final json = {
        'username': 'johndoe',
        'modelCount': 15,
        'link': 'https://civitai.com/user/johndoe',
        'image': 'https://image.civitai.com/avatar.jpg',
      };
      final creator = Creator.fromJson(json);
      expect(creator.username, 'johndoe');
      expect(creator.modelCount, 15);
      expect(creator.link, 'https://civitai.com/user/johndoe');
      expect(creator.image, 'https://image.civitai.com/avatar.jpg');
    });

    test('fromJson with minimal fields (username may be null from API)', () {
      final json = {'username': null};
      final creator = Creator.fromJson(json);
      expect(creator.username, '');
      expect(creator.modelCount, isNull);
    });

    test('fromJson empty object', () {
      final creator = Creator.fromJson({});
      expect(creator.username, '');
      expect(creator.modelCount, isNull);
      expect(creator.link, isNull);
      expect(creator.image, isNull);
    });

    test('copyWith', () {
      final c = Creator(username: 'old', modelCount: 5);
      final updated = c.copyWith(username: 'new');
      expect(updated.username, 'new');
      expect(updated.modelCount, 5);
    });
  });

  group('CreatorsResponse', () {
    test('fromJson with items and metadata', () {
      final json = {
        'items': [
          {'username': 'user1', 'modelCount': 2},
          {'username': 'user2', 'modelCount': 8},
        ],
        'metadata': {
          'totalItems': 2,
          'currentPage': 1,
          'pageSize': 100,
          'totalPages': 1,
        },
      };
      final response = CreatorsResponse.fromJson(json);
      expect(response.items.length, 2);
      expect(response.items[0].username, 'user1');
      expect(response.items[1].username, 'user2');
      expect(response.metadata.totalItems, 2);
      expect(response.metadata.currentPage, 1);
    });

    test('fromJson empty items', () {
      final response = CreatorsResponse.fromJson(<String, dynamic>{
        'items': <Map<String, dynamic>>[],
        'metadata': <String, dynamic>{},
      });
      expect(response.items, isEmpty);
      expect(response.metadata, isA<PaginationMetadata>());
    });
  });
}
