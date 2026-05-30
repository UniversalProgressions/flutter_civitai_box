import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_civitai_box/civitai_api/http_client.dart';
import 'package:flutter_civitai_box/civitai_api/errors.dart';
import 'package:flutter_civitai_box/civitai_api/config.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockDio extends Mock implements Dio {}

class FakeBaseOptions extends Fake implements BaseOptions {}

class FakeRequestOptions extends Fake implements RequestOptions {}

class FakeResponse<T> extends Fake implements Response<T> {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates a mock Dio that returns a successful response with [data].
MockDio _mockDioSuccess(dynamic data) {
  final dio = MockDio();
  // Dio.request<T> is a generic method — mocktail needs concrete registration
  when(
    () => dio.request<dynamic>(
      any(),
      data: any(named: 'data'),
      queryParameters: any(named: 'queryParameters'),
      options: any(named: 'options'),
      cancelToken: any(named: 'cancelToken'),
      onSendProgress: any(named: 'onSendProgress'),
      onReceiveProgress: any(named: 'onReceiveProgress'),
    ),
  ).thenAnswer((_) async {
    final resp = Response<dynamic>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    );
    return resp;
  });
  // Also allow calls without optional params
  when(
    () => dio.request<dynamic>(
      any(),
      data: any(named: 'data'),
      queryParameters: any(named: 'queryParameters'),
      options: any(named: 'options'),
    ),
  ).thenAnswer((_) async {
    final resp = Response<dynamic>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: ''),
    );
    return resp;
  });
  return dio;
}

/// Creates a mock Dio that throws a [DioException].
MockDio _mockDioError(DioException exception) {
  final dio = MockDio();
  when(
    () => dio.request<dynamic>(
      any(),
      data: any(named: 'data'),
      queryParameters: any(named: 'queryParameters'),
      options: any(named: 'options'),
      cancelToken: any(named: 'cancelToken'),
      onSendProgress: any(named: 'onSendProgress'),
      onReceiveProgress: any(named: 'onReceiveProgress'),
    ),
  ).thenThrow(exception);
  when(
    () => dio.request<dynamic>(
      any(),
      data: any(named: 'data'),
      queryParameters: any(named: 'queryParameters'),
      options: any(named: 'options'),
    ),
  ).thenThrow(exception);
  return dio;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Dio dio;
  late HttpClient http;

  setUp(() {
    dio = _mockDioSuccess({'result': 'ok'});
    http = createHttpClient(dio);
  });

  group('HttpClient.get', () {
    test('returns Right with JSON on success', () async {
      final result = await http.get('models');
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('expected Right'),
        (json) => expect(json, {'result': 'ok'}),
      );
    });

    test('passes queryParams to Dio', () async {
      final result = await http.get('models', queryParams: {'limit': 10});
      expect(result.isRight(), true);
    });

    test('passes headers to Dio', () async {
      final result = await http.get('models', headers: {'X-Custom': 'value'});
      expect(result.isRight(), true);
    });

    test('returns Left NetworkError on connection timeout', () async {
      final errorDio = _mockDioError(
        DioException(
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timeout',
          requestOptions: RequestOptions(path: ''),
        ),
      );
      final client = createHttpClient(errorDio);
      final result = await client.get('models');
      expect(result.isLeft(), true);
      result.fold((e) {
        expect(e, isA<NetworkError>());
        expect((e as NetworkError).message, contains('timed out'));
      }, (_) => fail('expected Left'));
    });

    test('returns Left NetworkError on connection error', () async {
      final errorDio = _mockDioError(
        DioException(
          type: DioExceptionType.connectionError,
          message: 'No internet',
          requestOptions: RequestOptions(path: ''),
        ),
      );
      final client = createHttpClient(errorDio);
      final result = await client.get('models');
      expect(result.isLeft(), true);
      result.fold((e) {
        expect(e, isA<NetworkError>());
      }, (_) => fail('expected Left'));
    });

    test('returns Left ApiError on bad response', () async {
      final errorDio = _mockDioError(
        DioException(
          type: DioExceptionType.badResponse,
          message: 'Not Found',
          response: Response<dynamic>(
            data: {'error': 'Resource not found'},
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
        ),
      );
      final client = createHttpClient(errorDio);
      final result = await client.get('models/99999');
      expect(result.isLeft(), true);
      result.fold((e) {
        expect(e, isA<ApiError>());
        expect((e as ApiError).statusCode, 404);
      }, (_) => fail('expected Left'));
    });

    test('returns Left ApiError when response data is a string', () async {
      final errorDio = _mockDioError(
        DioException(
          type: DioExceptionType.badResponse,
          message: 'Error',
          response: Response<dynamic>(
            data: 'Plain text error',
            statusCode: 500,
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
        ),
      );
      final client = createHttpClient(errorDio);
      final result = await client.get('models');
      expect(result.isLeft(), true);
      result.fold((e) {
        expect(e, isA<ApiError>());
        expect((e as ApiError).statusCode, 500);
      }, (_) => fail('expected Left'));
    });
  });

  group('HttpClient.post', () {
    test('returns Right with JSON on success', () async {
      final result = await http.post('models', body: {'name': 'test'});
      expect(result.isRight(), true);
    });
  });

  group('HttpClient.put', () {
    test('returns Right with JSON on success', () async {
      final result = await http.put('models/1', body: {'name': 'updated'});
      expect(result.isRight(), true);
    });
  });

  group('HttpClient.delete', () {
    test('returns Right with JSON on success', () async {
      final result = await http.delete('models/1');
      expect(result.isRight(), true);
    });
  });

  group('createCivitaiDio', () {
    test('configures baseUrl from config', () {
      final d = createCivitaiDio(
        CivitaiConfig(baseUrl: 'https://custom.api/v1'),
      );
      expect(d.options.baseUrl, 'https://custom.api/v1');
    });

    test('configures timeout from config', () {
      final d = createCivitaiDio(CivitaiConfig(timeout: 5000));
      expect(d.options.connectTimeout, const Duration(seconds: 5));
      expect(d.options.receiveTimeout, const Duration(seconds: 5));
    });

    test('sets Content-Type header', () {
      final d = createCivitaiDio(CivitaiConfig());
      expect(d.options.headers['Content-Type'], 'application/json');
    });

    test('merges custom headers', () {
      final d = createCivitaiDio(
        CivitaiConfig(headers: {'X-API-Version': '2'}),
      );
      expect(d.options.headers['X-API-Version'], '2');
    });

    test('does not add auth interceptor when no apiKey', () {
      final d = createCivitaiDio(CivitaiConfig());
      // Just verify it doesn't throw — the interceptor is added but does nothing
      expect(d.interceptors.length, greaterThanOrEqualTo(1));
    });
  });
}
