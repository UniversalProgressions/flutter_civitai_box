import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_civitai_box/civitai_api/civitai_api.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockDio extends Mock implements Dio {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('createCivitaiApi', () {
    test('creates API with default baseUrl when none provided', () {
      final api = createCivitaiApi();
      expect(api.models, isNotNull);
      expect(api.creators, isNotNull);
      expect(api.modelVersions, isNotNull);
      expect(api.tags, isNotNull);
    });

    test('creates API with custom baseUrl', () {
      final api = createCivitaiApi(baseUrl: 'https://custom.api/v1');
      expect(api.models, isNotNull);
    });

    test('creates API with apiKey', () {
      final api = createCivitaiApi(apiKey: 'test-key-123');
      expect(api.models, isNotNull);
    });

    test('all endpoint records are structurally typed correctly', () {
      final api = createCivitaiApi();

      // Verify the record fields exist (structural typing)
      expect(api.models.list, isA<Function>());
      expect(api.models.getById, isA<Function>());
      expect(api.models.getModel, isA<Function>());
      expect(api.models.nextPage, isA<Function>());

      expect(api.creators.list, isA<Function>());

      expect(api.modelVersions.getById, isA<Function>());
      expect(api.modelVersions.getByHash, isA<Function>());
      expect(api.modelVersions.resolveFileDownloadUrl, isA<Function>());

      expect(api.tags.list, isA<Function>());
    });
  });

  group('createCivitaiApiFromConfig', () {
    test('creates API from CivitaiConfig', () {
      final config = CivitaiConfig(
        apiKey: 'key',
        baseUrl: 'https://test.api/v1',
        timeout: 10000,
      );
      final api = createCivitaiApiFromConfig(config);
      expect(api.models, isNotNull);
      expect(api.creators, isNotNull);
    });
  });

  group('CivitaiApi typedef', () {
    test('can destructure record fields', () {
      final api = createCivitaiApi();
      final (:models, :creators, :modelVersions, :tags) = api;
      expect(models, isNotNull);
      expect(creators, isNotNull);
      expect(modelVersions, isNotNull);
      expect(tags, isNotNull);
    });
  });

  group('Exports', () {
    test('all model types are exported', () {
      // Just verify the types compile — implicit test
      expect(CivitaiConfig, isNotNull);
      expect(CivitaiError.api, isA<Function>());
    });
  });
}
