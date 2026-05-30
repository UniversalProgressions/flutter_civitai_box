import 'package:test/test.dart';

import 'package:flutter_civitai_box/civitai_api/models/request_options.dart';
import 'package:flutter_civitai_box/civitai_api/models/enums.dart';

void main() {
  group('ModelsRequestOptions', () {
    test('empty (all nulls)', () {
      final opts = ModelsRequestOptions();
      expect(opts.limit, isNull);
      expect(opts.page, isNull);
      expect(opts.query, isNull);
      expect(opts.tag, isNull);
    });

    test('with scalar fields', () {
      final opts = ModelsRequestOptions(
        limit: 20,
        page: 1,
        query: 'pony',
        username: 'creator1',
        sort: ModelsSort.newest,
        period: ModelsPeriod.month,
        rating: 8,
        favorites: true,
        hidden: false,
        primaryFileOnly: true,
        allowDifferentLicenses: true,
        nsfw: false,
        supportsGeneration: true,
      );
      expect(opts.limit, 20);
      expect(opts.query, 'pony');
      expect(opts.sort, ModelsSort.newest);
      expect(opts.period, ModelsPeriod.month);
      expect(opts.favorites, true);
    });

    test('with enum list fields', () {
      final opts = ModelsRequestOptions(
        types: [ModelType.lora, ModelType.checkpoint],
        allowCommercialUse: [AllowCommercialUse.sell, AllowCommercialUse.rent],
        checkpointType: CheckpointType.trained,
        baseModels: [BaseModel.sd15, BaseModel.sdxl10, BaseModel.pony],
      );
      expect(opts.types!.length, 2);
      expect(opts.types![0], ModelType.lora);
      expect(opts.allowCommercialUse!.length, 2);
      expect(opts.baseModels!.length, 3);
      expect(opts.checkpointType, CheckpointType.trained);
    });

    test('with string list field (tag)', () {
      final opts = ModelsRequestOptions(tag: ['anime', 'portrait']);
      expect(opts.tag, ['anime', 'portrait']);
    });

    test('copyWith preserves other fields', () {
      final opts = ModelsRequestOptions(limit: 10, query: 'test');
      final updated = opts.copyWith(limit: 50);
      expect(updated.limit, 50);
      expect(updated.query, 'test');
    });

    test('fromJson / toJson roundtrip', () {
      final original = ModelsRequestOptions(
        limit: 30,
        query: 'test',
        sort: ModelsSort.mostDownloaded,
      );
      final json = original.toJson();
      final restored = ModelsRequestOptions.fromJson(json);
      expect(restored.limit, 30);
      expect(restored.query, 'test');
      expect(restored.sort, ModelsSort.mostDownloaded);
    });
  });

  group('CreatorsRequestOptions', () {
    test('defaults are null', () {
      final opts = CreatorsRequestOptions();
      expect(opts.limit, isNull);
      expect(opts.query, isNull);
    });

    test('with values', () {
      final opts = CreatorsRequestOptions(limit: 10, query: 'john');
      expect(opts.limit, 10);
      expect(opts.query, 'john');
    });

    test('copyWith', () {
      final opts = CreatorsRequestOptions(limit: 5);
      expect(opts.copyWith(query: 'q').query, 'q');
      expect(opts.copyWith(query: 'q').limit, 5);
    });
  });

  group('TagsRequestOptions', () {
    test('defaults are null', () {
      final opts = TagsRequestOptions();
      expect(opts.limit, isNull);
      expect(opts.query, isNull);
    });

    test('with values', () {
      final opts = TagsRequestOptions(limit: 50, query: 'anime');
      expect(opts.limit, 50);
      expect(opts.query, 'anime');
    });

    test('copyWith', () {
      final opts = TagsRequestOptions(limit: 10);
      expect(opts.copyWith(limit: 20).limit, 20);
      expect(opts.copyWith(query: 'x').query, 'x');
    });
  });
}
