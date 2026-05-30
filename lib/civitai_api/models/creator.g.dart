// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creator.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Creator _$CreatorFromJson(Map<String, dynamic> json) => _Creator(
  username: json['username'] as String? ?? '',
  modelCount: (json['modelCount'] as num?)?.toInt(),
  link: json['link'] as String?,
  image: json['image'] as String?,
);

Map<String, dynamic> _$CreatorToJson(_Creator instance) => <String, dynamic>{
  'username': instance.username,
  'modelCount': instance.modelCount,
  'link': instance.link,
  'image': instance.image,
};

_CreatorsResponse _$CreatorsResponseFromJson(Map<String, dynamic> json) =>
    _CreatorsResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => Creator.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] == null
          ? const PaginationMetadata()
          : PaginationMetadata.fromJson(
              json['metadata'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$CreatorsResponseToJson(_CreatorsResponse instance) =>
    <String, dynamic>{'items': instance.items, 'metadata': instance.metadata};
