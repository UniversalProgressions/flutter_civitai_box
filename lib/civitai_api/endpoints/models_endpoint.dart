import 'package:dio/dio.dart';

import '../models/model.dart';
import '../models/model_id.dart';
import '../models/request_options.dart';
import '../utils.dart';

/// Endpoint for /models — list, get by ID, pagination.
class ModelsEndpoint {
  final Dio _dio;

  ModelsEndpoint(this._dio);

  /// GET /models — list/search models.
  Future<ModelsResponse> list([ModelsRequestOptions? opts]) async {
    try {
      final response = await _dio.get(
        'models',
        queryParameters: opts != null
            ? obj2QueryParams(_requestOptionsToJson(opts))
            : null,
      );
      return ModelsResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// GET /models/:id — get a model by ID (returns ModelById format).
  Future<ModelById> getById(int id) async {
    try {
      final response = await _dio.get('models/$id');
      return ModelById.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// GET /models/:id — get a model and convert to the list-compatible [Model] format.
  Future<Model> getModel(int id) async {
    final modelById = await getById(id);
    return modelId2Model(modelById);
  }

  /// GET a pagination URL (next page from metadata).
  Future<ModelsResponse> nextPage(String url) async {
    // Strip base URL prefix to get relative path
    String path = url;
    try {
      final uri = Uri.parse(url);
      if (uri.host.isNotEmpty) {
        path = uri.path;
        if (uri.hasQuery) path += '?${uri.query}';
      }
    } catch (_) {
      // Use as-is
    }
    if (path.startsWith('/')) path = path.substring(1);

    try {
      final response = await _dio.get(path);
      return ModelsResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

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
