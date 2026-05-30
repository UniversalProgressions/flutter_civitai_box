import 'package:freezed_annotation/freezed_annotation.dart';

import 'shared.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

/// A single tag item from the tags endpoint.
@freezed
abstract class TagItem with _$TagItem {
  const factory TagItem({
    required String name,
    required int modelCount,
    required String link,
  }) = _TagItem;

  factory TagItem.fromJson(Map<String, dynamic> json) =>
      _$TagItemFromJson(json);
}

/// Response from GET /tags.
@freezed
abstract class TagsResponse with _$TagsResponse {
  const factory TagsResponse({
    required List<TagItem> items,
    @Default(PaginationMetadata()) PaginationMetadata metadata,
  }) = _TagsResponse;

  factory TagsResponse.fromJson(Map<String, dynamic> json) =>
      _$TagsResponseFromJson(json);
}
