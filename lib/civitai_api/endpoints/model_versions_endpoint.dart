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
  /// Follows redirects WITHOUT downloading the file body (reads the `Location`
  /// header instead), so resolving is cheap even for large files.
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
          // Do NOT follow redirects: we only need the `Location` header, not
          // the file body. Following redirects would download the ENTIRE file
          // into memory just to learn its URL — a major cause of slow starts
          // and double downloads.
          followRedirects: false,
          // Treat every status as success so 3xx redirects can be inspected.
          validateStatus: (_) => true,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Authorization': 'Bearer $authToken'},
        ),
      );
      final response = await resolveDio.getUri(Uri.parse(fileUrl));
      final status = response.statusCode ?? 0;

      // Redirect → return the target URL from the Location header.
      if (status >= 300 && status < 400) {
        final location = response.headers.value('location');
        if (location != null && location.isNotEmpty) {
          return Uri.parse(fileUrl).resolve(location).toString();
        }
      }
      if (status == 401) {
        throw const CivitaiApiException(
          401,
          'Unauthorized to access file. You may need to purchase this model.',
        );
      }
      if (status >= 400) {
        throw CivitaiApiException(
          status,
          'Failed to resolve download URL (HTTP $status)',
        );
      }
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
