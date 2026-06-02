import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_civitai_box/civitai_api/endpoints/tags_endpoint.dart';
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

void main() {
  group('TagsEndpoint.list', () {
    test('returns TagsResponse on success', () async {
      final endpoint = TagsEndpoint(_mockDioSuccess(_tagsResponseJson()));
      final response = await endpoint.list();
      expect(response.items.length, 2);
      expect(response.items[0].name, 'anime');
      expect(response.items[0].modelCount, 500);
      expect(response.items[1].name, 'portrait');
      expect(response.items[1].modelCount, 300);
      expect(response.metadata.totalItems, 2);
    });

    test('handles empty items', () async {
      final json = <String, dynamic>{
        'items': <Map<String, dynamic>>[],
        'metadata': <String, dynamic>{},
      };
      final endpoint = TagsEndpoint(_mockDioSuccess(json));
      final response = await endpoint.list();
      expect(response.items, isEmpty);
    });

    test('throws ApiException on 503', () async {
      final dio = MockDio();
      when(
        () => dio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          message: 'Service Unavailable',
          response: Response<dynamic>(
            data: {'error': 'Down'},
            statusCode: 503,
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
        ),
      );
      final endpoint = TagsEndpoint(dio);
      expect(
        () => endpoint.list(),
        throwsA(
          isA<CivitaiApiException>().having(
            (e) => e.statusCode,
            'statusCode',
            503,
          ),
        ),
      );
    });

    test('throws NetworkException on DNS error', () async {
      final dio = MockDio();
      when(
        () => dio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          type: DioExceptionType.connectionError,
          message: 'DNS error',
          requestOptions: RequestOptions(path: ''),
        ),
      );
      final endpoint = TagsEndpoint(dio);
      expect(() => endpoint.list(), throwsA(isA<CivitaiNetworkException>()));
    });
  });
}
