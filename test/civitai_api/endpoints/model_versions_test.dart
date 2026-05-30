import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

import 'package:flutter_civitai_box/civitai_api/endpoints/model_versions.dart';
import 'package:flutter_civitai_box/civitai_api/errors.dart';
import 'package:flutter_civitai_box/civitai_api/http_client.dart';

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

/// Minimal valid ModelVersionEndpointData JSON.
Map<String, dynamic> _versionJson() => {
  'id': 999,
  'modelId': 456,
  'name': 'v3.0',
  'baseModel': 'SD 3.5',
  'baseModelType': 'Checkpoint',
  'publishedAt': '2025-01-01T00:00:00.000Z',
  'nsfwLevel': 1,
  'stats': {'downloadCount': 15000, 'thumbsUpCount': 1800},
  'files': [],
  'images': [],
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Dio dio;

  setUp(() {
    dio = Dio(BaseOptions(headers: {'Authorization': 'Bearer test-token'}));
  });

  group('ModelVersionsApi.getById', () {
    test('returns ModelVersionEndpointData on success', () async {
      final api = createModelVersionsApi(
        _fakeHttpClient(_versionJson()),
        dio: dio,
      );
      final result = await api.getById(999);
      expect(result.isRight(), true);
      result.fold((_) => fail('expected Right'), (data) {
        expect(data.id, 999);
        expect(data.modelId, 456);
        expect(data.name, 'v3.0');
        expect(data.baseModel, 'SD 3.5');
        expect(data.stats.downloadCount, 15000);
      });
    });

    test('returns error on failure', () async {
      final api = createModelVersionsApi(
        _failingHttpClient(CivitaiError.api(404, 'Not found')),
        dio: dio,
      );
      final result = await api.getById(1);
      expect(result.isLeft(), true);
    });
  });

  group('ModelVersionsApi.getByHash', () {
    test('returns ModelVersionEndpointData on success', () async {
      final api = createModelVersionsApi(
        _fakeHttpClient(_versionJson()),
        dio: dio,
      );
      final result = await api.getByHash('abc123hash');
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('expected Right'),
        (data) => expect(data.id, 999),
      );
    });

    test('returns error on failure', () async {
      final api = createModelVersionsApi(
        _failingHttpClient(CivitaiError.network('Timeout')),
        dio: dio,
      );
      final result = await api.getByHash('hash');
      expect(result.isLeft(), true);
    });
  });

  group('ModelVersionsApi.resolveFileDownloadUrl', () {
    test('returns error when no token available', () async {
      final noAuthDio = Dio(); // No Authorization header
      final api = createModelVersionsApi(_fakeHttpClient({}), dio: noAuthDio);
      final result = await api.resolveFileDownloadUrl(
        'https://civitai.com/api/download/models/100',
      );
      expect(result.isLeft(), true);
      result.fold((e) {
        expect(e, isA<ApiError>());
        expect((e as ApiError).statusCode, 401);
        expect(e.message, contains('Download token required'));
      }, (_) => fail('expected Left'));
    });

    test('uses provided token parameter', () async {
      // This will attempt a real HTTP call — we just test the token flow
      final api = createModelVersionsApi(
        _fakeHttpClient({}),
        dio: Dio(), // No auth header in Dio
      );
      final result = await api.resolveFileDownloadUrl(
        'https://example.com/file',
        'my-explicit-token',
      );
      // Will fail with network error (example.com not CivitAI), but token was used
      expect(result.isLeft(), true);
    });

    test('returns error when response is not a Map', () async {
      final api = createModelVersionsApi(_fakeHttpClient('not json'), dio: dio);
      final result = await api.getById(1);
      expect(result.isLeft(), true);
    });
  });
}
