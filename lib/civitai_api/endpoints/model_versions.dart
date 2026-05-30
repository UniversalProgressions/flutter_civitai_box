import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../errors.dart';
import '../http_client.dart';
import '../models/model_version.dart';

// ---------------------------------------------------------------------------
// Type
// ---------------------------------------------------------------------------

/// Model Versions API.
typedef ModelVersionsApi = ({
  Future<Either<CivitaiError, ModelVersionEndpointData>> Function(int) getById,
  Future<Either<CivitaiError, ModelVersionEndpointData>> Function(String)
  getByHash,
  Future<Either<CivitaiError, String>> Function(String, [String?])
  resolveFileDownloadUrl,
});

// ---------------------------------------------------------------------------
// Factory
// ---------------------------------------------------------------------------

/// Creates the [ModelVersionsApi] module, capturing [client] in closures.
///
/// [dio] is needed separately for `resolveFileDownloadUrl` because it follows
/// redirects to resolve CDN URLs — a raw Dio instance with redirect enabled
/// works better than the general [HttpClient] for this case.
ModelVersionsApi createModelVersionsApi(
  HttpClient client, {
  required Dio dio,
}) => (
  // GET /model-versions/:id
  getById: (int id) async {
    final result = await client.get('model-versions/$id');
    return result.flatMap(
      (json) => _decodeResponse<ModelVersionEndpointData>(
        json,
        ModelVersionEndpointData.fromJson,
        'model-version $id',
      ),
    );
  },

  // GET /model-versions/by-hash/:hash
  getByHash: (String hash) async {
    final result = await client.get('model-versions/by-hash/$hash');
    return result.flatMap(
      (json) => _decodeResponse<ModelVersionEndpointData>(
        json,
        ModelVersionEndpointData.fromJson,
        'model-version by hash $hash',
      ),
    );
  },

  // Resolve a file download URL → final CDN URL after redirects
  resolveFileDownloadUrl: (String fileUrl, [String? token]) async {
    // Use provided token, or get from Dio's auth header
    final authToken =
        token ??
        (dio.options.headers['Authorization'] as String?)?.replaceFirst(
          'Bearer ',
          '',
        );

    if (authToken == null || authToken.isEmpty) {
      return left(
        const CivitaiError.api(
          401,
          'Download token required. Provide apiKey in config.',
        ),
      );
    }

    try {
      // Use a separate Dio instance with redirect following enabled
      final resolveDio = Dio(
        BaseOptions(
          followRedirects: true,
          headers: {'Authorization': 'Bearer $authToken'},
        ),
      );
      final response = await resolveDio.getUri(Uri.parse(fileUrl));
      // response.realUri contains the final URL after redirects
      return right(response.realUri.toString());
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 0;
      if (statusCode == 401) {
        return left(
          CivitaiError.api(
            statusCode,
            'Unauthorized to access file. You may need to purchase this model.',
          ),
        );
      }
      return left(
        CivitaiError.api(
          statusCode,
          'Failed to resolve download URL: ${e.message}',
        ),
      );
    } catch (e) {
      return left(CivitaiError.network('Network error resolving URL: $e', e));
    }
  },
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Either<CivitaiError, T> _decodeResponse<T>(
  dynamic json,
  T Function(Map<String, dynamic>) fromJson,
  String context,
) {
  if (json is! Map<String, dynamic>) {
    return left(CivitaiError.api(0, 'Unexpected response type for $context'));
  }
  try {
    return right(fromJson(json));
  } catch (e) {
    return left(CivitaiError.api(0, 'Failed to decode $context: $e'));
  }
}
