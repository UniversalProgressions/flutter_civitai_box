import 'package:dio/dio.dart';

import '../../services/logger.dart';
import '../civitai_api_exception.dart';
import '../models/model_version.dart';
import '../utils.dart';

/// Endpoint for /model-versions.
class ModelVersionsEndpoint {
  final Dio _dio;

  ModelVersionsEndpoint(this._dio);

  /// GET /model-versions/:id — get a model version by ID.
  Future<ModelVersionEndpointData> getById(int id) async {
    try {
      final response = await _dio.get('model-versions/$id');
      return ModelVersionEndpointData.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    } catch (e, st) {
      logger.error('ModelVersionEndpointData.fromJson failed', e, st);
      rethrow;
    }
  }

  /// GET /model-versions/by-hash/:hash — get a model version by file hash.
  Future<ModelVersionEndpointData> getByHash(String hash) async {
    try {
      final response = await _dio.get('model-versions/by-hash/$hash');
      return ModelVersionEndpointData.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    } catch (e, st) {
      logger.error('ModelVersionEndpointData.fromJson (by-hash) failed', e, st);
      rethrow;
    }
  }

  /// Resolve a file download URL → final CDN URL after redirects.
  ///
  /// Uses a separate Dio instance with `followRedirects` enabled.
  /// [token] overrides the API key from config if provided.
  Future<String> resolveFileDownloadUrl(String fileUrl, [String? token]) async {
    // Use provided token, or get from Dio's auth header
    final authToken =
        token ??
        (_dio.options.headers['Authorization'] as String?)?.replaceFirst(
          'Bearer ',
          '',
        );

    if (authToken == null || authToken.isEmpty) {
      throw const CivitaiApiException(
        401,
        'Download token required. Provide apiKey in config.',
      );
    }

    try {
      final resolveDio = Dio(
        BaseOptions(
          followRedirects: true,
          headers: {'Authorization': 'Bearer $authToken'},
        ),
      );
      final response = await resolveDio.getUri(Uri.parse(fileUrl));
      return response.realUri.toString();
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 0;
      if (statusCode == 401) {
        throw CivitaiApiException(
          statusCode,
          'Unauthorized to access file. You may need to purchase this model.',
        );
      }
      throw CivitaiApiException(
        statusCode,
        'Failed to resolve download URL: ${e.message}',
      );
    } catch (e) {
      throw CivitaiNetworkException('Network error resolving URL: $e', e);
    }
  }
}
