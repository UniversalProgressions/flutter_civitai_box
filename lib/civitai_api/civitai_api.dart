/// CivitAI API Client — Simple OOP Dart library.
///
/// Provides a straightforward interface to the CivitAI REST API using Dio
/// for HTTP, Freezed for immutable data models, and try/catch for error handling.
///
/// ## Usage
///
/// ```dart
/// final api = CivitaiApiClient(apiKey: 'your-api-key');
///
/// // List models
/// try {
///   final response = await api.models.list(
///     ModelsRequestOptions(limit: 20, query: 'pony'),
///   );
///   print('Found ${response.items.length} models');
/// } on CivitaiApiException catch (e) {
///   print('API error ${e.statusCode}: ${e.message}');
/// } on CivitaiNetworkException catch (e) {
///   print('Network error: ${e.message}');
/// }
///
/// // Chain calls naturally
/// try {
///   final model = await api.models.getById(123);
///   final version = await api.modelVersions.getById(model.modelVersions.first.id);
///   final downloadUrl = await api.modelVersions
///       .resolveFileDownloadUrl(version.files.first.downloadUrl);
///   print('Download: $downloadUrl');
/// } on CivitaiApiException catch (e) {
///   print('Error: ${e.message}');
/// }
/// ```
library;

import 'package:dio/dio.dart';

import 'endpoints/creators_endpoint.dart';
import 'endpoints/model_versions_endpoint.dart';
import 'endpoints/models_endpoint.dart';
import 'endpoints/tags_endpoint.dart';

// ---------------------------------------------------------------------------
// Re-exports
// ---------------------------------------------------------------------------

export 'civitai_api_exception.dart';
export 'endpoints/creators_endpoint.dart';
export 'endpoints/model_versions_endpoint.dart';
export 'endpoints/models_endpoint.dart';
export 'endpoints/tags_endpoint.dart';
export 'models/creator.dart';
export 'models/enums.dart';
export 'models/model.dart';
export 'models/model_id.dart';
export 'models/model_version.dart';
export 'models/request_options.dart';
export 'models/shared.dart';
export 'models/tag.dart';
export 'utils.dart';

// ---------------------------------------------------------------------------
// Main API client
// ---------------------------------------------------------------------------

/// The complete CivitAI API client.
///
/// Holds a [Dio] instance and exposes endpoint objects for each API resource.
///
/// ```dart
/// final api = CivitaiApiClient(apiKey: 'my-key');
/// final models = await api.models.list();
/// ```
class CivitaiApiClient {
  final Dio _dio;

  late final ModelsEndpoint models = ModelsEndpoint(_dio);
  late final CreatorsEndpoint creators = CreatorsEndpoint(_dio);
  late final ModelVersionsEndpoint modelVersions = ModelVersionsEndpoint(_dio);
  late final TagsEndpoint tags = TagsEndpoint(_dio);

  CivitaiApiClient({
    String? apiKey,
    String baseUrl = 'https://civitai.com/api/v1',
    int timeout = 30000,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
           connectTimeout: Duration(milliseconds: timeout),
           receiveTimeout: Duration(milliseconds: timeout),
           headers: {
             if (apiKey != null && apiKey.isNotEmpty)
               'Authorization': 'Bearer $apiKey',
           },
         ),
       );
}
