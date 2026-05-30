/// CivitAI API Client — Functional Dart library.
///
/// Provides a pure functional interface to the CivitAI REST API using
/// [dartz] `Either` for railway-oriented error handling and Freezed for
/// immutable data models.
///
/// ## Usage
///
/// ```dart
/// final api = createCivitaiApi(apiKey: 'your-api-key');
///
/// // List models
/// final result = await api.models.list(
///   ModelsRequestOptions(limit: 20, query: 'pony'),
/// );
///
/// result.fold(
///   (error) => switch (error) {
///     ApiError(:final message) => print('API error: $message'),
///     NetworkError(:final message) => print('Network error: $message'),
///   },
///   (response) => print('Found ${response.items.length} models'),
/// );
///
/// // Compose with flatMap
/// final downloadUrl = await api.models
///     .getById(123)
///     .flatMap((m) => api.modelVersions
///         .getById(m.modelVersions.first.id))
///     .flatMap((mv) => api.modelVersions
///         .resolveFileDownloadUrl(mv.files.first.downloadUrl));
/// ```
library;

import 'config.dart';
import 'endpoints/creators.dart';
import 'endpoints/model_versions.dart';
import 'endpoints/models.dart';
import 'endpoints/tags.dart';
import 'http_client.dart';

// ---------------------------------------------------------------------------
// Re-exports
// ---------------------------------------------------------------------------

export 'config.dart';
export 'endpoints/creators.dart';
export 'endpoints/model_versions.dart';
export 'endpoints/models.dart';
export 'endpoints/tags.dart';
export 'errors.dart';
export 'http_client.dart';
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
// Main API type
// ---------------------------------------------------------------------------

/// The complete CivitAI API surface — a record of endpoint modules.
typedef CivitaiApi = ({
  ModelsApi models,
  CreatorsApi creators,
  ModelVersionsApi modelVersions,
  TagsApi tags,
});

// ---------------------------------------------------------------------------
// Factory
// ---------------------------------------------------------------------------

/// Creates the full [CivitaiApi] with all endpoint modules wired up.
///
/// ```dart
/// final api = createCivitaiApi(apiKey: 'my-key');
/// ```
CivitaiApi createCivitaiApi({
  String? apiKey,
  String? baseUrl,
  int timeout = 30000,
  bool validateResponses = false,
}) {
  final config = CivitaiConfig(
    apiKey: apiKey ?? '',
    baseUrl: baseUrl ?? 'https://civitai.com/api/v1',
    timeout: timeout,
    validateResponses: validateResponses,
  );
  return createCivitaiApiFromConfig(config);
}

/// Creates the full [CivitaiApi] from an existing [CivitaiConfig].
CivitaiApi createCivitaiApiFromConfig(CivitaiConfig config) {
  final dio = createCivitaiDio(config);
  final http = createHttpClient(dio);

  return (
    models: createModelsApi(http),
    creators: createCreatorsApi(http),
    modelVersions: createModelVersionsApi(http, dio: dio),
    tags: createTagsApi(http),
  );
}
