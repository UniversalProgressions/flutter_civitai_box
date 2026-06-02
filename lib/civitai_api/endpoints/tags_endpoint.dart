import 'package:dio/dio.dart';

import '../models/request_options.dart';
import '../models/tag.dart';
import '../utils.dart';

/// Endpoint for /tags.
class TagsEndpoint {
  final Dio _dio;

  TagsEndpoint(this._dio);

  /// GET /tags — list/search tags.
  Future<TagsResponse> list([TagsRequestOptions? opts]) async {
    try {
      final response = await _dio.get(
        'tags',
        queryParameters: opts != null
            ? obj2QueryParams(_optsToJson(opts))
            : null,
      );
      return TagsResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}

Map<String, dynamic> _optsToJson(TagsRequestOptions opts) {
  final map = <String, dynamic>{};
  if (opts.limit != null) map['limit'] = opts.limit;
  if (opts.query != null) map['query'] = opts.query;
  return map;
}
