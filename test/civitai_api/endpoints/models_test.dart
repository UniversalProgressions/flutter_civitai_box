import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_civitai_box/civitai_api/endpoints/models_endpoint.dart';
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

MockDio _mockDioError(DioException exception) {
  final dio = MockDio();
  when(
    () => dio.get(any(), queryParameters: any(named: 'queryParameters')),
  ).thenThrow(exception);
  return dio;
}

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

void main() {
  group('ModelsEndpoint.list', () {
    test('returns ModelsResponse on success', () async {
      final endpoint = ModelsEndpoint(_mockDioSuccess(_modelsResponseJson()));
      final response = await endpoint.list();
      expect(response.items.length, 1);
      expect(response.items[0].name, 'Model One');
      expect(response.metadata.totalItems, 1);
    });

    test('throws ApiException on HTTP 500', () async {
      final endpoint = ModelsEndpoint(
        _mockDioError(
          DioException(
            type: DioExceptionType.badResponse,
            message: 'Server error',
            response: Response<dynamic>(
              data: {'error': 'Server error'},
              statusCode: 500,
              requestOptions: RequestOptions(path: ''),
            ),
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );
      expect(
        () => endpoint.list(),
        throwsA(
          isA<CivitaiApiException>().having(
            (e) => e.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
    });

    test('throws NetworkException on connection error', () async {
      final endpoint = ModelsEndpoint(
        _mockDioError(
          DioException(
            type: DioExceptionType.connectionError,
            message: 'No internet',
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );
      expect(() => endpoint.list(), throwsA(isA<CivitaiNetworkException>()));
    });
  });

  group('ModelsEndpoint.getById', () {
    test('returns ModelById on success', () async {
      final endpoint = ModelsEndpoint(_mockDioSuccess(_modelByIdJson()));
      final model = await endpoint.getById(123);
      expect(model.id, 123);
      expect(model.name, 'Test Model');
      expect(model.modelVersions.length, 1);
    });

    test('throws on 404', () async {
      final endpoint = ModelsEndpoint(
        _mockDioError(
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
        ),
      );
      expect(
        () => endpoint.getById(99999),
        throwsA(isA<CivitaiApiException>()),
      );
    });
  });

  group('ModelsEndpoint.getModel', () {
    test('converts ModelById to Model', () async {
      final endpoint = ModelsEndpoint(_mockDioSuccess(_modelByIdJson()));
      final model = await endpoint.getModel(123);
      expect(model.id, 123);
      expect(model.name, 'Test Model');
    });
  });
}
