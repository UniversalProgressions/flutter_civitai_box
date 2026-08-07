import 'dart:io';

import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_civitai_box/civitai_api/endpoints/model_versions_endpoint.dart';
import 'package:flutter_civitai_box/civitai_api/civitai_api_exception.dart';

class MockDio extends Mock implements Dio {}

MockDio _mockDioSuccess(dynamic data) {
  final dio = MockDio();
  when(
    () => dio.get(any(), queryParameters: any(named: 'queryParameters')),
  ).thenAnswer(
    (_) async => Response<dynamic>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    ),
  );
  return dio;
}

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

void main() {
  group('ModelVersionsEndpoint.getById', () {
    test('returns ModelVersionEndpointData on success', () async {
      final endpoint = ModelVersionsEndpoint(_mockDioSuccess(_versionJson()));
      final data = await endpoint.getById(999);
      expect(data.id, 999);
      expect(data.modelId, 456);
      expect(data.name, 'v3.0');
      expect(data.baseModel, 'SD 3.5');
      expect(data.stats.downloadCount, 15000);
    });

    test('throws ApiException on 404', () async {
      final dio = MockDio();
      when(
        () => dio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          message: 'Not Found',
          response: Response<dynamic>(
            data: {'error': 'Not found'},
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
        ),
      );
      final endpoint = ModelVersionsEndpoint(dio);
      expect(() => endpoint.getById(1), throwsA(isA<CivitaiApiException>()));
    });
  });

  group('ModelVersionsEndpoint.getByHash', () {
    test('returns ModelVersionEndpointData on success', () async {
      final endpoint = ModelVersionsEndpoint(_mockDioSuccess(_versionJson()));
      final data = await endpoint.getByHash('abc123hash');
      expect(data.id, 999);
    });

    test('throws NetworkException on timeout', () async {
      final dio = MockDio();
      when(
        () => dio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          type: DioExceptionType.connectionTimeout,
          message: 'Timeout',
          requestOptions: RequestOptions(path: ''),
        ),
      );
      final endpoint = ModelVersionsEndpoint(dio);
      expect(
        () => endpoint.getByHash('hash'),
        throwsA(isA<CivitaiNetworkException>()),
      );
    });
  });

  group('ModelVersionsEndpoint.resolveFileDownloadUrl', () {
    test('throws ApiException when no token available', () async {
      final endpoint = ModelVersionsEndpoint(Dio());
      expect(
        () => endpoint.resolveFileDownloadUrl(
          'https://civitai.com/api/download/models/100',
        ),
        throwsA(
          isA<CivitaiApiException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having(
                (e) => e.message,
                'message',
                contains('Download token required'),
              ),
        ),
      );
    });

    test(
      'returns redirect target from Location header (no body download)',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final base = 'http://localhost:${server.port}';
        server.listen((request) {
          request.response
            ..statusCode = 302
            ..headers.set('location', '$base/final/file.safetensors')
            ..close();
        });

        try {
          final endpoint = ModelVersionsEndpoint(Dio());
          final result = await endpoint.resolveFileDownloadUrl(
            '$base/download',
            'test-token',
          );
          expect(result, '$base/final/file.safetensors');
        } finally {
          await server.close();
        }
      },
    );

    test('returns the url itself when there is no redirect', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final base = 'http://localhost:${server.port}';
      server.listen((request) {
        request.response
          ..statusCode = 200
          ..headers.set('content-type', 'text/plain')
          ..write('ok')
          ..close();
      });

      try {
        final endpoint = ModelVersionsEndpoint(Dio());
        final result = await endpoint.resolveFileDownloadUrl(
          '$base/file.txt',
          'test-token',
        );
        expect(result, '$base/file.txt');
      } finally {
        await server.close();
      }
    });
  });
}
