import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_civitai_box/civitai_api/endpoints/creators_endpoint.dart';
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

Map<String, dynamic> _creatorsResponseJson() => {
  'items': [
    {'username': 'creator1', 'modelCount': 5},
    {'username': 'creator2', 'modelCount': 12},
  ],
  'metadata': {'totalItems': 2, 'currentPage': 1},
};

void main() {
  group('CreatorsEndpoint.list', () {
    test('returns CreatorsResponse on success', () async {
      final endpoint = CreatorsEndpoint(
        _mockDioSuccess(_creatorsResponseJson()),
      );
      final response = await endpoint.list();
      expect(response.items.length, 2);
      expect(response.items[0].username, 'creator1');
      expect(response.items[1].modelCount, 12);
      expect(response.metadata.totalItems, 2);
    });

    test('handles empty items', () async {
      final json = <String, dynamic>{
        'items': <Map<String, dynamic>>[],
        'metadata': <String, dynamic>{},
      };
      final endpoint = CreatorsEndpoint(_mockDioSuccess(json));
      final response = await endpoint.list();
      expect(response.items, isEmpty);
    });

    test('throws NetworkException on connection error', () async {
      final dio = MockDio();
      when(
        () => dio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          type: DioExceptionType.connectionError,
          message: 'No connection',
          requestOptions: RequestOptions(path: ''),
        ),
      );
      final endpoint = CreatorsEndpoint(dio);
      expect(() => endpoint.list(), throwsA(isA<CivitaiNetworkException>()));
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
      final endpoint = CreatorsEndpoint(dio);
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
  });
}
