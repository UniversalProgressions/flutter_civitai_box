import 'dart:convert';
import 'dart:io';

import 'package:flutter_civitai_box/civitai_api/utils.dart';
import 'package:flutter_civitai_box/db/db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

/// Reads and decodes a JSON fixture from `test/data/`.
Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/data/$name').readAsStringSync())
        as Map<String, dynamic>;

/// Extract image ID from a modelVersion-endpoint image (which lacks an `id` field).
int _imageId(Map<String, dynamic> img) => extractIdFromImageUrl(
  img['url'] as String,
).fold((e) => throw Exception(e), (id) => id);

// ---------------------------------------------------------------------------
// Test suite
// ---------------------------------------------------------------------------
void main() {
  // Use FFI so sqflite runs on desktop / CI without a Flutter embedder.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // In-memory database — fast, zero cleanup, impossible to collide with
  // the production database on disk.
  const testDbPath = ':memory:';

  setUp(() async {
    await CivitaiDatabase.initForTest(testDbPath);
  });

  tearDown(() async {
    await CivitaiDatabase.instance.then((db) => db.close());
  });

  // =========================================================================
  // DAO — reference tables
  // =========================================================================
  group('DAO — reference tables', () {
    test('CreatorDao insert & getById', () async {
      const dao = CreatorDao();
      await dao.upsert({
        'username': 'testuser',
        'link': 'https://x.com/test',
        'image': null,
      });
      final row = await dao.getByUsername('testuser');
      expect(row, isNotNull);
      expect(row!['username'], 'testuser');
      expect(row['link'], 'https://x.com/test');
    });

    test('CreatorDao upsert overwrites existing', () async {
      const dao = CreatorDao();
      await dao.upsert({'username': 'dup', 'link': 'first'});
      await dao.upsert({'username': 'dup', 'link': 'second'});
      final row = await dao.getByUsername('dup');
      expect(row!['link'], 'second');
    });

    test('ModelTypeDao insert & getByName', () async {
      const dao = ModelTypeDao();
      await dao.upsert({'name': 'LORA'});
      final row = await dao.getByName('LORA');
      expect(row, isNotNull);
      expect(row!['name'], 'LORA');
    });

    test('TagDao search', () async {
      const dao = TagDao();
      await dao.upsert({'name': 'anime'});
      await dao.upsert({'name': 'animal'});
      await dao.upsert({'name': 'landscape'});

      final results = await dao.search('ani');
      expect(results.length, 2);
      final names = results.map((r) => r['name']).toSet();
      expect(names, containsAll(['anime', 'animal']));
    });

    test('BaseModelDao insert & getByName', () async {
      const dao = BaseModelDao();
      await dao.upsert({'name': 'SD 1.5'});
      final row = await dao.getByName('SD 1.5');
      expect(row, isNotNull);
    });

    test('BaseModelTypeDao insert & getByName', () async {
      // base_model_type has FK → base_model; insert the parent first.
      const baseDao = BaseModelDao();
      await baseDao.upsert({'name': 'SDXL'});
      final parent = await baseDao.getByName('SDXL');

      const dao = BaseModelTypeDao();
      await dao.upsert({'name': 'Standard', 'base_model_id': parent!['id']});
      final row = await dao.getByName('Standard');
      expect(row, isNotNull);
      expect(row!['base_model_id'], parent['id']);
    });
  });

  // =========================================================================
  // ModelRepository — upsert
  // =========================================================================
  group('ModelRepository.upsertModel', () {
    test('inserts a model with creator, type and tags', () async {
      final fixture = _fixture('models_endpoint_response.json');
      final item = (fixture['items'] as List).first as Map<String, dynamic>;

      const repo = ModelRepository();
      await repo.upsertModel(
        id: item['id'],
        name: item['name'],
        creatorJson: item['creator'] as Map<String, dynamic>?,
        modelTypeName: item['type'],
        tagNames: List<String>.from(item['tags']),
        nsfw: item['nsfw'] ?? false,
        nsfwLevel: item['nsfwLevel'],
        modelJson: item,
      );

      // Verify model row
      const modelDao = ModelDao();
      final model = await modelDao.getById(11821);
      expect(model, isNotNull);
      expect(model!['name'], 'VSK-94 | Girls\' Frontline');
      expect(model['type_id'], isNotNull);

      // Verify creator was created
      const creatorDao = CreatorDao();
      final creator = await creatorDao.getByUsername('LeonDoesntDraw');
      expect(creator, isNotNull);

      // Verify model type was created
      const typeDao = ModelTypeDao();
      final type = await typeDao.getByName('LORA');
      expect(type, isNotNull);

      // Verify tags were linked
      final tagIds = await modelDao.getTagIds(11821);
      expect(tagIds.length, 4); // anime, character, woman, girls_frontline
    });

    test('upserting again updates instead of duplicating', () async {
      final fixture = _fixture('models_endpoint_response.json');
      final item = (fixture['items'] as List).first as Map<String, dynamic>;

      const repo = ModelRepository();
      await repo.upsertModel(
        id: 11821,
        name: item['name'],
        creatorJson: item['creator'],
        modelTypeName: item['type'],
        tagNames: List<String>.from(item['tags']),
        nsfw: item['nsfw'] ?? false,
        nsfwLevel: item['nsfwLevel'],
        modelJson: item,
      );
      // Second upsert with different tags
      await repo.upsertModel(
        id: 11821,
        name: item['name'],
        creatorJson: item['creator'],
        modelTypeName: item['type'],
        tagNames: ['anime', 'woman'], // fewer tags
        nsfw: item['nsfw'] ?? false,
        nsfwLevel: item['nsfwLevel'],
        modelJson: item,
      );

      const modelDao = ModelDao();
      final tagIds = await modelDao.getTagIds(11821);
      expect(tagIds.length, 2); // only the new set
    });
  });

  // =========================================================================
  // ModelRepository — queryModels
  // =========================================================================
  group('ModelRepository.queryModels', () {
    setUp(() async {
      // Insert the single model from the fixture so we can query it.
      final fixture = _fixture('models_endpoint_response.json');
      final item = (fixture['items'] as List).first as Map<String, dynamic>;
      const repo = ModelRepository();
      await repo.upsertModel(
        id: 11821,
        name: item['name'],
        creatorJson: item['creator'],
        modelTypeName: item['type'],
        tagNames: List<String>.from(item['tags']),
        nsfw: item['nsfw'] ?? false,
        nsfwLevel: item['nsfwLevel'],
        modelJson: item,
      );
    });

    test('returns all models with no filters', () async {
      const repo = ModelRepository();
      final (:records, :totalCount) = await repo.queryModels();
      expect(totalCount, 1);
      expect(records.length, 1);
      expect(records.first['name'], 'VSK-94 | Girls\' Frontline');
      // JOIN columns present
      expect(records.first['creator_username'], 'LeonDoesntDraw');
      expect(records.first['type_name'], 'LORA');
    });

    test('filters by type', () async {
      const repo = ModelRepository();
      final result = await repo.queryModels(types: ['LORA']);
      expect(result.totalCount, 1);
      expect(result.records.length, 1);

      final noResult = await repo.queryModels(types: ['Checkpoint']);
      expect(noResult.totalCount, 0);
    });

    test('filters by tag', () async {
      const repo = ModelRepository();
      final result = await repo.queryModels(tags: ['anime']);
      expect(result.totalCount, 1);

      final noResult = await repo.queryModels(tags: ['nonexistent']);
      expect(noResult.totalCount, 0);
    });

    test('filters by username', () async {
      const repo = ModelRepository();
      final result = await repo.queryModels(username: 'LeonDoesntDraw');
      expect(result.totalCount, 1);

      final noResult = await repo.queryModels(username: 'Nobody');
      expect(noResult.totalCount, 0);
    });

    test('filters by name query', () async {
      const repo = ModelRepository();
      final result = await repo.queryModels(query: 'VSK');
      expect(result.totalCount, 1);

      final noResult = await repo.queryModels(query: 'zzznotfound');
      expect(noResult.totalCount, 0);
    });

    test('pagination — offset-based', () async {
      const repo = ModelRepository();
      final page1 = await repo.queryModels(limit: 10, page: 1);
      expect(page1.records.length, 1);
      final page2 = await repo.queryModels(limit: 10, page: 2);
      expect(page2.records, isEmpty);
    });
  });

  // =========================================================================
  // ModelVersionRepository — upsertVersion
  // =========================================================================
  group('ModelVersionRepository.upsertVersion', () {
    test(
      'inserts a version with images and files from modelVersion endpoint',
      () async {
        final fixture = _fixture('modelVersion_endpoint_response.json');

        final modelData = fixture['model'] as Map<String, dynamic>;
        final images = (fixture['images'] as List)
            .map(
              (img) => {
                'id': _imageId(img),
                'url': img['url'],
                'nsfwLevel': img['nsfwLevel'],
                'width': img['width'],
                'height': img['height'],
                'hash': img['hash'],
                'type': img['type'],
              },
            )
            .toList();
        final files = (fixture['files'] as List).map((f) {
          return {
            'id': f['id'],
            'sizeKB': f['sizeKB'],
            'name': f['name'],
            'type': f['type'],
            'downloadUrl': f['downloadUrl'],
          };
        }).toList();

        const repo = ModelVersionRepository();
        await repo.upsertVersion(
          id: fixture['id'],
          modelId: fixture['modelId'],
          name: fixture['name'],
          baseModelName: fixture['baseModel'],
          baseModelTypeName: fixture['baseModelType'],
          nsfwLevel: fixture['nsfwLevel'],
          versionJson: fixture,
          modelJson: modelData,
          modelName: modelData['name'],
          creatorJson: null,
          modelTypeName: modelData['type'],
          tagNames: [],
          modelNsfw: modelData['nsfw'] ?? false,
          modelNsfwLevel: 0,
          images: images,
          files: files,
        );

        // Verify model was created
        const modelDao = ModelDao();
        final model = await modelDao.getById(1595884);
        expect(model, isNotNull);
        expect(model!['name'], 'Hyphoria [Illu & NAI]');

        // Verify model version
        const versionDao = ModelVersionDao();
        final version = await versionDao.getById(1805971);
        expect(version, isNotNull);
        expect(version!['name'], 'v0.01');
        expect(version['base_model_id'], isNotNull);
        expect(version['base_model_type_id'], isNotNull);
        expect(version['nsfw_level'], 31);

        // Verify base model & type were created
        const baseDao = BaseModelDao();
        final baseModel = await baseDao.getByName('Illustrious');
        expect(baseModel, isNotNull);

        const baseTypeDao = BaseModelTypeDao();
        final baseType = await baseTypeDao.getByName('Standard');
        expect(baseType, isNotNull);

        // Verify images
        const imageDao = ModelVersionImageDao();
        final savedImages = await imageDao.getByModelVersion(1805971);
        expect(savedImages.length, 10);

        // Verify files
        const fileDao = ModelVersionFileDao();
        final savedFiles = await fileDao.getByModelVersion(1805971);
        expect(savedFiles.length, 1);
        expect(savedFiles.first['size_kb'], closeTo(6775429.97, 1.0));
        expect(savedFiles.first['name'], 'hyphoriaIlluNAI_v001.safetensors');
      },
    );
  });

  // =========================================================================
  // ModelVersionRepository — deleteVersion
  // =========================================================================
  group('ModelVersionRepository.deleteVersion', () {
    setUp(() async {
      // Insert a model + version so we can test deletion.
      final fixture = _fixture('modelVersion_endpoint_response.json');
      final modelData = fixture['model'] as Map<String, dynamic>;
      final images = (fixture['images'] as List)
          .map(
            (img) => {
              'id': _imageId(img),
              'url': img['url'],
              'nsfwLevel': img['nsfwLevel'],
              'width': img['width'],
              'height': img['height'],
              'hash': img['hash'],
              'type': img['type'],
            },
          )
          .toList();
      final files = (fixture['files'] as List).map((f) {
        return {
          'id': f['id'],
          'sizeKB': f['sizeKB'],
          'name': f['name'],
          'type': f['type'],
          'downloadUrl': f['downloadUrl'],
        };
      }).toList();

      const repo = ModelVersionRepository();
      await repo.upsertVersion(
        id: fixture['id'],
        modelId: fixture['modelId'],
        name: fixture['name'],
        baseModelName: fixture['baseModel'],
        baseModelTypeName: fixture['baseModelType'],
        nsfwLevel: fixture['nsfwLevel'],
        versionJson: fixture,
        modelJson: modelData,
        modelName: modelData['name'],
        creatorJson: null,
        modelTypeName: modelData['type'],
        tagNames: [],
        modelNsfw: modelData['nsfw'] ?? false,
        modelNsfwLevel: 0,
        images: images,
        files: files,
      );
    });

    test('deletes version, images, files, and orphan model', () async {
      const repo = ModelVersionRepository();
      final result = await repo.deleteVersion(1805971);

      expect(result.deleted, true);
      expect(result.modelDeleted, true); // model had only 1 version
      expect(result.fileCount, 1);
      expect(result.imageCount, 10);

      // Verify everything is gone
      const versionDao = ModelVersionDao();
      expect(await versionDao.getById(1805971), isNull);

      const modelDao = ModelDao();
      expect(await modelDao.getById(1595884), isNull);

      const imageDao = ModelVersionImageDao();
      expect((await imageDao.getByModelVersion(1805971)), isEmpty);

      const fileDao = ModelVersionFileDao();
      expect((await fileDao.getByModelVersion(1805971)), isEmpty);
    });
  });

  // =========================================================================
  // ModelVersionRepository — deleteMultipleVersions
  // =========================================================================
  group('ModelVersionRepository.deleteMultipleVersions', () {
    test('batch deletes with per-item results and error collection', () async {
      // Insert two versions belonging to the same model.
      final fixture = _fixture('modelVersion_endpoint_response.json');
      final modelData = fixture['model'] as Map<String, dynamic>;

      Future<void> insertVersion(int id, String name) async {
        final images = (fixture['images'] as List)
            .map(
              (img) => {
                'id': _imageId(img),
                'url': img['url'],
                'nsfwLevel': img['nsfwLevel'],
                'width': img['width'],
                'height': img['height'],
                'hash': img['hash'],
                'type': img['type'],
              },
            )
            .toList();
        final files = (fixture['files'] as List).map((f) {
          return {
            'id': f['id'],
            'sizeKB': f['sizeKB'],
            'name': f['name'],
            'type': f['type'],
            'downloadUrl': f['downloadUrl'],
          };
        }).toList();
        const repo = ModelVersionRepository();
        await repo.upsertVersion(
          id: id,
          modelId: fixture['modelId'],
          name: name,
          baseModelName: fixture['baseModel'],
          baseModelTypeName: fixture['baseModelType'],
          nsfwLevel: fixture['nsfwLevel'],
          versionJson: fixture,
          modelJson: modelData,
          modelName: modelData['name'],
          creatorJson: null,
          modelTypeName: modelData['type'],
          tagNames: [],
          modelNsfw: modelData['nsfw'] ?? false,
          modelNsfwLevel: 0,
          images: images,
          files: files,
        );
      }

      await insertVersion(1805971, 'v0.01');
      await insertVersion(1805972, 'v0.02'); // fictional second version

      // Delete both + one nonexistent
      const repo = ModelVersionRepository();
      final result = await repo.deleteMultipleVersions([
        1805971,
        1805972,
        999999,
      ]);

      expect(result.total, 3);
      expect(result.succeeded, 2);
      expect(result.failed, 1);
      expect(result.results[0].success, true);
      expect(result.results[0].modelDeleted, false); // model still has v0.02
      expect(result.results[1].success, true);
      expect(result.results[1].modelDeleted, true); // last version → model gone
      expect(result.results[2].success, false);
      expect(result.results[2].error, isNotNull);
    });
  });

  // =========================================================================
  // Edge cases
  // =========================================================================
  group('Edge cases', () {
    test('upsertModel with null creator', () async {
      const repo = ModelRepository();
      await repo.upsertModel(
        id: 99999,
        name: 'No Creator Model',
        creatorJson: null,
        modelTypeName: 'Checkpoint',
        tagNames: [],
        nsfw: false,
        nsfwLevel: 0,
        modelJson: {'id': 99999, 'name': 'No Creator Model'},
      );

      const dao = ModelDao();
      final model = await dao.getById(99999);
      expect(model, isNotNull);
      expect(model!['creator_id'], isNull);
    });

    test('upsertModel with empty tags', () async {
      const repo = ModelRepository();
      await repo.upsertModel(
        id: 88888,
        name: 'Tagless',
        creatorJson: null,
        modelTypeName: 'VAE',
        tagNames: [],
        nsfw: false,
        nsfwLevel: 0,
        modelJson: {'id': 88888, 'name': 'Tagless'},
      );

      const dao = ModelDao();
      final model = await dao.getById(88888);
      expect(model, isNotNull);
      expect(await dao.getTagIds(88888), isEmpty);
    });

    test('upsertVersion with null baseModelType', () async {
      const repo = ModelVersionRepository();
      await repo.upsertVersion(
        id: 77777,
        modelId: 66666,
        name: 'No Subtype',
        baseModelName: 'SDXL',
        baseModelTypeName: null,
        nsfwLevel: 0,
        versionJson: {'id': 77777},
        modelJson: {
          'id': 66666,
          'name': 'Parent',
          'type': 'Checkpoint',
          'nsfw': false,
        },
        modelName: 'Parent',
        creatorJson: null,
        modelTypeName: 'Checkpoint',
        tagNames: [],
        modelNsfw: false,
        modelNsfwLevel: 0,
        images: [],
        files: [],
      );

      const versionDao = ModelVersionDao();
      final v = await versionDao.getById(77777);
      expect(v, isNotNull);
      expect(v!['base_model_type_id'], isNull);
    });
  });
}
