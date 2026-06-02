import 'package:dio/dio.dart';

import '../models/creator.dart';
import '../models/request_options.dart';
import '../utils.dart';

/// Endpoint for /creators.
class CreatorsEndpoint {
  final Dio _dio;

  CreatorsEndpoint(this._dio);

  /// GET /creators — list/search creators.
  Future<CreatorsResponse> list([CreatorsRequestOptions? opts]) async {
    try {
      final response = await _dio.get(
        'creators',
        queryParameters: opts != null
            ? obj2QueryParams(_optsToJson(opts))
            : null,
      );
      return CreatorsResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}

Map<String, dynamic> _optsToJson(CreatorsRequestOptions opts) {
  final map = <String, dynamic>{};
  if (opts.limit != null) map['limit'] = opts.limit;
  if (opts.query != null) map['query'] = opts.query;
  return map;
}
