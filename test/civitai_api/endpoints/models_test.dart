import 'package:dartz/dartz.dart';
import 'package:test/test.dart';

import 'package:flutter_civitai_box/civitai_api/endpoints/models.dart';
import 'package:flutter_civitai_box/civitai_api/errors.dart';
import 'package:flutter_civitai_box/civitai_api/http_client.dart';
import 'package:flutter_civitai_box/civitai_api/models/request_options.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates a fake [HttpClient] that returns [responseJson] for any GET call.
HttpClient _fakeHttpClient(dynamic responseJson) => (
  get:
      (
        String path, {
        Map<String, dynamic>? queryParams,
        Map<String, String>? headers,
      }) async => right(responseJson),
  post:
      (
        String path, {
        dynamic body,
        Map<String, dynamic>? queryParams,
        Map<String, String>? headers,
      }) async => left(CivitaiError.api(405, 'Not used')),
  put:
      (
        String path, {
        dynamic body,
        Map<String, dynamic>? queryParams,
        Map<String, String>? headers,
      }) async => left(CivitaiError.api(405, 'Not used')),
  delete:
      (
        String path, {
        Map<String, dynamic>? queryParams,
        Map<String, String>? headers,
      }) async => left(CivitaiError.api(405, 'Not used')),
);

/// Creates a fake [HttpClient] that returns [error] for any GET call.
HttpClient _failingHttpClient(CivitaiError error) => (
  get:
      (
        String path, {
        Map<String, dynamic>? queryParams,
        Map<String, String>? headers,
      }) async => left(error),
  post:
      (
        String path, {
        dynamic body,
        Map<String, dynamic>? queryParams,
        Map<String, String>? headers,
      }) async => left(CivitaiError.api(405, 'Not used')),
  put:
      (
        String path, {
        dynamic body,
        Map<String, dynamic>? queryParams,
        Map<String, String>? headers,
      }) async => left(CivitaiError.api(405, 'Not used')),
  delete:
      (
        String path, {
        Map<String, dynamic>? queryParams,
        Map<String, String>? headers,
      }) async => left(CivitaiError.api(405, 'Not used')),
);

/// Minimal valid ModelsResponse JSON.
Map<String, dynamic> _modelsResponseJson() => {
  'items': [
    {
      'id': 1,
      'name': 'Model One',
      'nsfwLevel': 0,
      'modelVersions': [
        {
          'id': 10,
          'index': 0,
          'name': 'v1',
          'baseModel': 'SD 1.5',
          'nsfwLevel': 0,
        },
      ],
    },
  ],
  'metadata': {'totalItems': 1, 'currentPage': 1},
};

/// Minimal valid ModelById JSON.
Map<String, dynamic> _modelByIdJson() => {
  'id': 123,
  'name': 'Test Model',
  'description': 'A test',
  'type': 'Checkpoint',
  'poi': false,
  'nsfw': false,
  'nsfwLevel': 1,
  'stats': {
    'downloadCount': 100,
    'thumbsUpCount': 10,
    'commentCount': 5,
    'tippedAmountCount': 0,
  },
  'tags': ['test'],
  'modelVersions': [
    {
      'id': 1,
      'index': 0,
      'name': 'v1',
      'baseModel': 'SD 1.5',
      'nsfwLevel': 0,
      'images': [
        {
          'url': 'https://image.civitai.com/x/width=1024/42.jpeg',
          'nsfwLevel': 0,
          'width': 1024,
          'height': 768,
          'hash': 'abc',
          'type': 'image',
        },
      ],
    },
  ],
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ModelsApi.list', () {
    test('returns ModelsResponse on success', () async {
      final api = createModelsApi(_fakeHttpClient(_modelsResponseJson()));
      final result = await api.list();
      expect(result.isRight(), true);
      result.fold((_) => fail('expected Right'), (response) {
        expect(response.items.length, 1);
        expect(response.items[0].name, 'Model One');
        expect(response.metadata.totalItems, 1);
      });
    });

    test('passes query params with request options', () async {
      final api = createModelsApi(_fakeHttpClient(_modelsResponseJson()));
      final result = await api.list(
        ModelsRequestOptions(limit: 10, query: 'pony'),
      );
      expect(result.isRight(), true);
    });

    test('returns ApiError when response is not a Map', () async {
      final api = createModelsApi(_fakeHttpClient('not a json object'));
      final result = await api.list();
      expect(result.isLeft(), true);
      result.fold((e) {
        expect(e, isA<ApiError>());
      }, (_) => fail('expected Left'));
    });

    test('returns ApiError on HTTP failure', () async {
      final api = createModelsApi(
        _failingHttpClient(CivitaiError.api(500, 'Server error')),
      );
      final result = await api.list();
      expect(result.isLeft(), true);
      result.fold((e) {
        expect(e, isA<ApiError>());
        expect((e as ApiError).statusCode, 500);
      }, (_) => fail('expected Left'));
    });
  });

  group('ModelsApi.getById', () {
    test('returns ModelById on success', () async {
      final api = createModelsApi(_fakeHttpClient(_modelByIdJson()));
      final result = await api.getById(123);
      expect(result.isRight(), true);
      result.fold((_) => fail('expected Right'), (model) {
        expect(model.id, 123);
        expect(model.name, 'Test Model');
        expect(model.modelVersions.length, 1);
      });
    });

    test('returns error when response is not JSON', () async {
      final api = createModelsApi(_fakeHttpClient('plain text'));
      final result = await api.getById(1);
      expect(result.isLeft(), true);
    });
  });

  group('ModelsApi.getModel', () {
    test('converts ModelById to Model', () async {
      final api = createModelsApi(_fakeHttpClient(_modelByIdJson()));
      final result = await api.getModel(123);
      expect(result.isRight(), true);
      result.fold((_) => fail('expected Right'), (model) {
        expect(model.id, 123);
        expect(model.name, 'Test Model');
        // ModelVersion images should have id field (from ModelImageWithId)
        expect(model.modelVersions[0].images[0].id, 42);
      });
    });

    test('returns error when underlying getById fails', () async {
      final api = createModelsApi(
        _failingHttpClient(CivitaiError.network('Offline')),
      );
      final result = await api.getModel(1);
      expect(result.isLeft(), true);
    });
  });

  group('ModelsApi.nextPage', () {
    test('strips base URL and returns ModelsResponse', () async {
      final api = createModelsApi(_fakeHttpClient(_modelsResponseJson()));
      final result = await api.nextPage(
        'https://civitai.com/api/v1/models?page=2&limit=100',
      );
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('expected Right'),
        (response) => expect(response.items.length, 1),
      );
    });

    test('handles relative path directly', () async {
      final api = createModelsApi(_fakeHttpClient(_modelsResponseJson()));
      final result = await api.nextPage('models?page=2');
      expect(result.isRight(), true);
    });

    test('handles invalid URL as-is', () async {
      final api = createModelsApi(_fakeHttpClient(_modelsResponseJson()));
      final result = await api.nextPage('not-a-valid-url:::');
      expect(result.isRight(), true);
    });
  });
}
