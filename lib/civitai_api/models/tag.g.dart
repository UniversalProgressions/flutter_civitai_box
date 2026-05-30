// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TagItem _$TagItemFromJson(Map<String, dynamic> json) => _TagItem(
  name: json['name'] as String,
  modelCount: (json['modelCount'] as num).toInt(),
  link: json['link'] as String,
);

Map<String, dynamic> _$TagItemToJson(_TagItem instance) => <String, dynamic>{
  'name': instance.name,
  'modelCount': instance.modelCount,
  'link': instance.link,
};

_TagsResponse _$TagsResponseFromJson(Map<String, dynamic> json) =>
    _TagsResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => TagItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] == null
          ? const PaginationMetadata()
          : PaginationMetadata.fromJson(
              json['metadata'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$TagsResponseToJson(_TagsResponse instance) =>
    <String, dynamic>{'items': instance.items, 'metadata': instance.metadata};
