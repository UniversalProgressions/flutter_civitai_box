import 'package:dartz/dartz.dart';

import '../errors.dart';
import '../http_client.dart';
import '../models/creator.dart';
import '../models/request_options.dart';
import '../utils.dart';

// ---------------------------------------------------------------------------
// Type
// ---------------------------------------------------------------------------

/// Creators API — a record of functions for interacting with /creators.
typedef CreatorsApi = ({
  Future<Either<CivitaiError, CreatorsResponse>> Function([
    CreatorsRequestOptions?,
  ])
  list,
});

// ---------------------------------------------------------------------------
// Factory
// ---------------------------------------------------------------------------

/// Creates the [CreatorsApi] module, capturing [client] in closures.
CreatorsApi createCreatorsApi(HttpClient client) => (
  list: ([CreatorsRequestOptions? opts]) async {
    final result = await client.get(
      'creators',
      queryParams: opts != null ? obj2QueryParams(_optsToJson(opts)) : null,
    );
    return result.flatMap(
      (json) => _decodeResponse<CreatorsResponse>(
        json,
        CreatorsResponse.fromJson,
        'creators',
      ),
    );
  },
);

Map<String, dynamic> _optsToJson(CreatorsRequestOptions opts) {
  final map = <String, dynamic>{};
  if (opts.limit != null) map['limit'] = opts.limit;
  if (opts.query != null) map['query'] = opts.query;
  return map;
}

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
