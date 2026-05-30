import 'package:dartz/dartz.dart';

import '../errors.dart';
import '../http_client.dart';
import '../models/request_options.dart';
import '../models/tag.dart';
import '../utils.dart';

// ---------------------------------------------------------------------------
// Type
// ---------------------------------------------------------------------------

/// Tags API — a record of functions for interacting with /tags.
typedef TagsApi = ({
  Future<Either<CivitaiError, TagsResponse>> Function([TagsRequestOptions?])
  list,
});

// ---------------------------------------------------------------------------
// Factory
// ---------------------------------------------------------------------------

/// Creates the [TagsApi] module, capturing [client] in closures.
TagsApi createTagsApi(HttpClient client) => (
  list: ([TagsRequestOptions? opts]) async {
    final result = await client.get(
      'tags',
      queryParams: opts != null ? obj2QueryParams(_optsToJson(opts)) : null,
    );
    return result.flatMap(
      (json) =>
          _decodeResponse<TagsResponse>(json, TagsResponse.fromJson, 'tags'),
    );
  },
);

Map<String, dynamic> _optsToJson(TagsRequestOptions opts) {
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
