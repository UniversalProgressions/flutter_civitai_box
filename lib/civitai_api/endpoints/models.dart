import 'package:dartz/dartz.dart';

import '../errors.dart';
import '../http_client.dart';
import '../models/model.dart';
import '../models/model_id.dart';
import '../models/request_options.dart';
import '../utils.dart';

// ---------------------------------------------------------------------------
// Type
// ---------------------------------------------------------------------------

/// Models API — a record of functions for interacting with /models.
typedef ModelsApi = ({
  Future<Either<CivitaiError, ModelsResponse>> Function([ModelsRequestOptions?])
  list,
  Future<Either<CivitaiError, ModelById>> Function(int) getById,
  Future<Either<CivitaiError, Model>> Function(int) getModel,
  Future<Either<CivitaiError, ModelsResponse>> Function(String) nextPage,
});

// ---------------------------------------------------------------------------
// Factory
// ---------------------------------------------------------------------------

/// Creates the [ModelsApi] module, capturing [client] in closures.
ModelsApi createModelsApi(HttpClient client) => (
  // GET /models
  list: ([ModelsRequestOptions? opts]) async {
    final result = await client.get(
      'models',
      queryParams: opts != null
          ? obj2QueryParams(_requestOptionsToJson(opts))
          : null,
    );
    return result.flatMap(
      (json) => _decodeResponse<ModelsResponse>(
        json,
        ModelsResponse.fromJson,
        'models list',
      ),
    );
  },

  // GET /models/:id
  getById: (int id) async {
    final result = await client.get('models/$id');
    return result.flatMap(
      (json) =>
          _decodeResponse<ModelById>(json, ModelById.fromJson, 'model $id'),
    );
  },

  // GET /models/:id → converted to Model format
  getModel: (int id) async {
    final result = await client.get('models/$id');
    return result.flatMap((json) {
      final decoded = _decodeResponse<ModelById>(
        json,
        ModelById.fromJson,
        'model $id',
      );
      return decoded.flatMap((modelById) {
        final converted = modelId2Model(modelById);
        return converted.fold(
          (err) => left(CivitaiError.api(0, err)),
          (model) => right(model),
        );
      });
    });
  },

  // GET <nextPageUrl>
  nextPage: (String url) async {
    // Strip base URL prefix if present to get the relative path
    String path = url;
    try {
      final uri = Uri.parse(url);
      if (uri.host.isNotEmpty) {
        path = uri.path;
        if (uri.hasQuery) path += '?${uri.query}';
      }
    } catch (_) {
      // Not a valid URL, use as-is (probably already a relative path)
    }
    // Remove leading slash — Dio with baseUrl handles it
    if (path.startsWith('/')) path = path.substring(1);

    final result = await client.get(path);
    return result.flatMap(
      (json) => _decodeResponse<ModelsResponse>(
        json,
        ModelsResponse.fromJson,
        'next page',
      ),
    );
  },
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Safely decodes a JSON map into a Freezed model, wrapping errors as
/// [CivitaiError.api].
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

/// Converts [ModelsRequestOptions] to a plain map for query params,
/// mapping enum values to their string representations.
Map<String, dynamic> _requestOptionsToJson(ModelsRequestOptions opts) {
  final map = <String, dynamic>{};

  if (opts.limit != null) map['limit'] = opts.limit;
  if (opts.page != null) map['page'] = opts.page;
  if (opts.query != null) map['query'] = opts.query;
  if (opts.tag != null && opts.tag!.isNotEmpty) map['tag'] = opts.tag;
  if (opts.username != null) map['username'] = opts.username;
  if (opts.types != null && opts.types!.isNotEmpty) {
    map['types'] = opts.types!.map((e) => e.value).toList();
  }
  if (opts.sort != null) map['sort'] = opts.sort!.value;
  if (opts.period != null) map['period'] = opts.period!.value;
  if (opts.rating != null) map['rating'] = opts.rating;
  if (opts.favorites != null) map['favorites'] = opts.favorites;
  if (opts.hidden != null) map['hidden'] = opts.hidden;
  if (opts.primaryFileOnly != null) {
    map['primaryFileOnly'] = opts.primaryFileOnly;
  }
  if (opts.allowDifferentLicenses != null) {
    map['allowDifferentLicenses'] = opts.allowDifferentLicenses;
  }
  if (opts.allowCommercialUse != null && opts.allowCommercialUse!.isNotEmpty) {
    map['allowCommercialUse'] = opts.allowCommercialUse!
        .map((e) => e.value)
        .toList();
  }
  if (opts.nsfw != null) map['nsfw'] = opts.nsfw;
  if (opts.supportsGeneration != null) {
    map['supportsGeneration'] = opts.supportsGeneration;
  }
  if (opts.checkpointType != null) {
    map['checkpointType'] = opts.checkpointType!.value;
  }
  if (opts.baseModels != null && opts.baseModels!.isNotEmpty) {
    map['baseModels'] = opts.baseModels!.map((e) => e.value).toList();
  }

  return map;
}
