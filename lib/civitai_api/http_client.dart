import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'config.dart';
import 'errors.dart';

// ---------------------------------------------------------------------------
// Type aliases
// ---------------------------------------------------------------------------

/// HTTP GET function — returns raw decoded JSON as [Either].
typedef HttpGet =
    Future<Either<CivitaiError, dynamic>> Function(
      String path, {
      Map<String, dynamic>? queryParams,
      Map<String, String>? headers,
    });

/// HTTP POST function.
typedef HttpPost =
    Future<Either<CivitaiError, dynamic>> Function(
      String path, {
      dynamic body,
      Map<String, dynamic>? queryParams,
      Map<String, String>? headers,
    });

/// HTTP PUT function.
typedef HttpPut =
    Future<Either<CivitaiError, dynamic>> Function(
      String path, {
      dynamic body,
      Map<String, dynamic>? queryParams,
      Map<String, String>? headers,
    });

/// HTTP DELETE function.
typedef HttpDelete =
    Future<Either<CivitaiError, dynamic>> Function(
      String path, {
      Map<String, dynamic>? queryParams,
      Map<String, String>? headers,
    });

/// HTTP client — a record of HTTP verb functions, each returning [Either].
typedef HttpClient = ({
  HttpGet get,
  HttpPost post,
  HttpPut put,
  HttpDelete delete,
});

// ---------------------------------------------------------------------------
// Factory
// ---------------------------------------------------------------------------

/// Creates an [HttpClient] from an existing [Dio] instance.
///
/// All HTTP methods return `Either<CivitaiError, dynamic>`. Callers decode
/// the response body using Freezed `fromJson` factories.
///
/// ```dart
/// final dio = Dio(BaseOptions(baseUrl: 'https://civitai.com/api/v1'));
/// final http = createHttpClient(dio);
/// final result = await http.get('models', queryParams: {'limit': 10});
/// result.fold(
///   (err) => print('Error: $err'),
///   (json) => print(ModelsResponse.fromJson(json)),
/// );
/// ```
HttpClient createHttpClient(Dio dio) => (
  get:
      (
        String path, {
        Map<String, dynamic>? queryParams,
        Map<String, String>? headers,
      }) => _request(
        dio,
        'GET',
        path,
        queryParams: queryParams,
        headers: headers,
      ),
  post:
      (
        String path, {
        dynamic body,
        Map<String, dynamic>? queryParams,
        Map<String, String>? headers,
      }) => _request(
        dio,
        'POST',
        path,
        body: body,
        queryParams: queryParams,
        headers: headers,
      ),
  put:
      (
        String path, {
        dynamic body,
        Map<String, dynamic>? queryParams,
        Map<String, String>? headers,
      }) => _request(
        dio,
        'PUT',
        path,
        body: body,
        queryParams: queryParams,
        headers: headers,
      ),
  delete:
      (
        String path, {
        Map<String, dynamic>? queryParams,
        Map<String, String>? headers,
      }) => _request(
        dio,
        'DELETE',
        path,
        queryParams: queryParams,
        headers: headers,
      ),
);

// ---------------------------------------------------------------------------
// Internal
// ---------------------------------------------------------------------------

Future<Either<CivitaiError, dynamic>> _request(
  Dio dio,
  String method,
  String path, {
  dynamic body,
  Map<String, dynamic>? queryParams,
  Map<String, String>? headers,
}) async {
  try {
    final response = await dio.request<dynamic>(
      path,
      data: body,
      queryParameters: queryParams,
      options: Options(method: method, headers: headers),
    );
    return right(response.data);
  } on DioException catch (e) {
    return left(_mapDioError(e));
  } catch (e) {
    return left(CivitaiError.network('Unexpected error: $e', e));
  }
}

CivitaiError _mapDioError(DioException e) {
  final msg = e.message ?? 'Unknown error';

  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => CivitaiError.network(
      'Request timed out: $msg',
      e,
    ),
    DioExceptionType.connectionError => CivitaiError.network(
      'Connection failed: $msg',
      e,
    ),
    DioExceptionType.badResponse => CivitaiError.api(
      e.response?.statusCode ?? 0,
      _extractApiMessage(e),
    ),
    _ => CivitaiError.network(msg, e),
  };
}

String _extractApiMessage(DioException e) {
  final data = e.response?.data;
  if (data is Map<String, dynamic>) {
    return (data['error'] ??
            data['message'] ??
            e.message ??
            'Unknown API error')
        .toString();
  }
  if (data is String) return data;
  return e.message ?? 'Unknown API error';
}

// ---------------------------------------------------------------------------
// Dio factory (convenience)
// ---------------------------------------------------------------------------

/// Creates a pre-configured [Dio] instance for CivitAI API.
///
/// Configures base URL, timeout, auth interceptor, and JSON content type.
Dio createCivitaiDio(CivitaiConfig config) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: Duration(milliseconds: config.timeout),
      receiveTimeout: Duration(milliseconds: config.timeout),
      headers: {'Content-Type': 'application/json', ...config.headers},
    ),
  );

  // Auth interceptor: attach API key as Bearer token
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (config.apiKey.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer ${config.apiKey}';
        }
        handler.next(options);
      },
    ),
  );

  return dio;
}
