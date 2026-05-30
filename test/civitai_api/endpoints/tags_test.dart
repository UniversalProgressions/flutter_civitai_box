import 'package:dartz/dartz.dart';
import 'package:test/test.dart';

import 'package:flutter_civitai_box/civitai_api/endpoints/tags.dart';
import 'package:flutter_civitai_box/civitai_api/errors.dart';
import 'package:flutter_civitai_box/civitai_api/http_client.dart';
import 'package:flutter_civitai_box/civitai_api/models/request_options.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

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

Map<String, dynamic> _tagsResponseJson() => {
  'items': [
    {
      'name': 'anime',
      'modelCount': 500,
      'link': 'https://civitai.com/tag/anime',
    },
    {
      'name': 'portrait',
      'modelCount': 300,
      'link': 'https://civitai.com/tag/portrait',
    },
  ],
  'metadata': {'totalItems': 2, 'currentPage': 1},
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TagsApi.list', () {
    test('returns TagsResponse on success', () async {
      final api = createTagsApi(_fakeHttpClient(_tagsResponseJson()));
      final result = await api.list();
      expect(result.isRight(), true);
      result.fold((_) => fail('expected Right'), (response) {
        expect(response.items.length, 2);
        expect(response.items[0].name, 'anime');
        expect(response.items[0].modelCount, 500);
        expect(response.items[1].name, 'portrait');
        expect(response.items[1].modelCount, 300);
        expect(response.metadata.totalItems, 2);
      });
    });

    test('passes query params with options', () async {
      final api = createTagsApi(_fakeHttpClient(_tagsResponseJson()));
      final result = await api.list(
        TagsRequestOptions(limit: 20, query: 'ani'),
      );
      expect(result.isRight(), true);
    });

    test('handles empty items', () async {
      final json = <String, dynamic>{
        'items': <Map<String, dynamic>>[],
        'metadata': <String, dynamic>{},
      };
      final api = createTagsApi(_fakeHttpClient(json));
      final result = await api.list();
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('expected Right'),
        (response) => expect(response.items, isEmpty),
      );
    });

    test('returns ApiError when response is not a Map', () async {
      final api = createTagsApi(_fakeHttpClient(42));
      final result = await api.list();
      expect(result.isLeft(), true);
      result.fold(
        (e) => expect(e, isA<ApiError>()),
        (_) => fail('expected Left'),
      );
    });

    test('returns error on network failure', () async {
      final api = createTagsApi(
        _failingHttpClient(CivitaiError.network('DNS error')),
      );
      final result = await api.list();
      expect(result.isLeft(), true);
      result.fold(
        (e) => expect(e, isA<NetworkError>()),
        (_) => fail('expected Left'),
      );
    });

    test('returns error on API failure', () async {
      final api = createTagsApi(
        _failingHttpClient(CivitaiError.api(503, 'Service Unavailable')),
      );
      final result = await api.list();
      expect(result.isLeft(), true);
      result.fold((e) {
        expect(e, isA<ApiError>());
        expect((e as ApiError).statusCode, 503);
      }, (_) => fail('expected Left'));
    });
  });
}
