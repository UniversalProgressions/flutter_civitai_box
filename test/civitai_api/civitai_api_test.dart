import 'package:test/test.dart';

import 'package:flutter_civitai_box/civitai_api/civitai_api.dart';

void main() {
  group('CivitaiApiClient', () {
    test('creates with defaults', () {
      final api = CivitaiApiClient();
      expect(api.models, isNotNull);
      expect(api.creators, isNotNull);
      expect(api.modelVersions, isNotNull);
      expect(api.tags, isNotNull);
    });

    test('creates with custom baseUrl', () {
      final api = CivitaiApiClient(baseUrl: 'https://custom.api/v1');
      expect(api.models, isNotNull);
    });

    test('creates with apiKey', () {
      final api = CivitaiApiClient(apiKey: 'test-key-123');
      expect(api.models, isNotNull);
    });

    test('creates with custom timeout', () {
      final api = CivitaiApiClient(timeout: 5000);
      expect(api.models, isNotNull);
    });

    test('endpoint types are correct', () {
      final api = CivitaiApiClient();

      expect(api.models, isA<ModelsEndpoint>());
      expect(api.creators, isA<CreatorsEndpoint>());
      expect(api.modelVersions, isA<ModelVersionsEndpoint>());
      expect(api.tags, isA<TagsEndpoint>());
    });

    test('endpoint methods are available', () {
      final api = CivitaiApiClient();

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
}
