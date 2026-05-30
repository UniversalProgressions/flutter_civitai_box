import 'package:test/test.dart';

import 'package:flutter_civitai_box/civitai_api/models/tag.dart';

void main() {
  group('TagItem', () {
    test('fromJson', () {
      final json = {
        'name': 'pony',
        'modelCount': 42,
        'link': 'https://civitai.com/tag/pony',
      };
      final tag = TagItem.fromJson(json);
      expect(tag.name, 'pony');
      expect(tag.modelCount, 42);
      expect(tag.link, 'https://civitai.com/tag/pony');
    });

    test('copyWith', () {
      final tag = TagItem(name: 'a', modelCount: 1, link: 'l');
      expect(tag.copyWith(name: 'b').name, 'b');
    });
  });

  group('TagsResponse', () {
    test('fromJson with items', () {
      final json = {
        'items': [
          {'name': 'tag1', 'modelCount': 10, 'link': 'https://x.com/t1'},
          {'name': 'tag2', 'modelCount': 20, 'link': 'https://x.com/t2'},
        ],
        'metadata': {'totalItems': 2, 'currentPage': 1},
      };
      final response = TagsResponse.fromJson(json);
      expect(response.items.length, 2);
      expect(response.items[0].name, 'tag1');
      expect(response.items[1].modelCount, 20);
      expect(response.metadata.totalItems, 2);
    });

    test('fromJson empty', () {
      final response = TagsResponse.fromJson(<String, dynamic>{
        'items': <Map<String, dynamic>>[],
        'metadata': <String, dynamic>{},
      });
      expect(response.items, isEmpty);
    });
  });
}
