// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ModelVersion _$ModelVersionFromJson(Map<String, dynamic> json) =>
    _ModelVersion(
      id: (json['id'] as num).toInt(),
      index: (json['index'] as num).toInt(),
      name: json['name'] as String,
      baseModel: json['baseModel'] as String,
      baseModelType: json['baseModelType'] as String?,
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      availability: json['availability'] as String? ?? 'Public',
      nsfwLevel: (json['nsfwLevel'] as num).toInt(),
      description: json['description'] as String?,
      trainedWords:
          (json['trainedWords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      stats: json['stats'] == null
          ? const ModelVersionStats()
          : ModelVersionStats.fromJson(json['stats'] as Map<String, dynamic>),
      files:
          (json['files'] as List<dynamic>?)
              ?.map((e) => ModelFile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => ModelImageWithId.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ModelVersionToJson(_ModelVersion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'index': instance.index,
      'name': instance.name,
      'baseModel': instance.baseModel,
      'baseModelType': instance.baseModelType,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'availability': instance.availability,
      'nsfwLevel': instance.nsfwLevel,
      'description': instance.description,
      'trainedWords': instance.trainedWords,
      'stats': instance.stats,
      'files': instance.files,
      'images': instance.images,
    };

_Model _$ModelFromJson(Map<String, dynamic> json) => _Model(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  type: json['type'] as String? ?? 'Other',
  poi: json['poi'] as bool? ?? false,
  nsfw: json['nsfw'] as bool? ?? false,
  nsfwLevel: (json['nsfwLevel'] as num).toInt(),
  creator: json['creator'] == null
      ? null
      : Creator.fromJson(json['creator'] as Map<String, dynamic>),
  stats: json['stats'] == null
      ? const ModelStats()
      : ModelStats.fromJson(json['stats'] as Map<String, dynamic>),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  modelVersions:
      (json['modelVersions'] as List<dynamic>?)
          ?.map((e) => ModelVersion.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ModelToJson(_Model instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': instance.type,
  'poi': instance.poi,
  'nsfw': instance.nsfw,
  'nsfwLevel': instance.nsfwLevel,
  'creator': instance.creator,
  'stats': instance.stats,
  'tags': instance.tags,
  'modelVersions': instance.modelVersions,
};

_ModelsResponse _$ModelsResponseFromJson(Map<String, dynamic> json) =>
    _ModelsResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => Model.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] == null
          ? const PaginationMetadata()
          : PaginationMetadata.fromJson(
              json['metadata'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ModelsResponseToJson(_ModelsResponse instance) =>
    <String, dynamic>{'items': instance.items, 'metadata': instance.metadata};
