import 'package:dartz/dartz.dart';
import 'package:test/test.dart';

import 'package:flutter_civitai_box/civitai_api/endpoints/creators.dart';
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

Map<String, dynamic> _creatorsResponseJson() => {
  'items': [
    {'username': 'creator1', 'modelCount': 5},
    {'username': 'creator2', 'modelCount': 12},
  ],
  'metadata': {'totalItems': 2, 'currentPage': 1},
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CreatorsApi.list', () {
    test('returns CreatorsResponse on success', () async {
      final api = createCreatorsApi(_fakeHttpClient(_creatorsResponseJson()));
      final result = await api.list();
      expect(result.isRight(), true);
      result.fold((_) => fail('expected Right'), (response) {
        expect(response.items.length, 2);
        expect(response.items[0].username, 'creator1');
        expect(response.items[1].modelCount, 12);
        expect(response.metadata.totalItems, 2);
      });
    });

    test('passes query params with options', () async {
      final api = createCreatorsApi(_fakeHttpClient(_creatorsResponseJson()));
      final result = await api.list(
        CreatorsRequestOptions(limit: 5, query: 'john'),
      );
      expect(result.isRight(), true);
    });

    test('handles empty items', () async {
      final json = <String, dynamic>{
        'items': <Map<String, dynamic>>[],
        'metadata': <String, dynamic>{},
      };
      final api = createCreatorsApi(_fakeHttpClient(json));
      final result = await api.list();
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('expected Right'),
        (response) => expect(response.items, isEmpty),
      );
    });

    test('returns ApiError when response is not a Map', () async {
      final api = createCreatorsApi(_fakeHttpClient([1, 2, 3]));
      final result = await api.list();
      expect(result.isLeft(), true);
      result.fold(
        (e) => expect(e, isA<ApiError>()),
        (_) => fail('expected Left'),
      );
    });

    test('returns error on HTTP failure', () async {
      final api = createCreatorsApi(
        _failingHttpClient(CivitaiError.network('No connection')),
      );
      final result = await api.list();
      expect(result.isLeft(), true);
      result.fold(
        (e) => expect(e, isA<NetworkError>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
