// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ModelVersionEndpointData _$ModelVersionEndpointDataFromJson(
  Map<String, dynamic> json,
) => _ModelVersionEndpointData(
  id: (json['id'] as num).toInt(),
  modelId: (json['modelId'] as num).toInt(),
  name: json['name'] as String,
  baseModel: json['baseModel'] as String,
  baseModelType: json['baseModelType'] as String?,
  publishedAt: DateTime.parse(json['publishedAt'] as String),
  nsfwLevel: (json['nsfwLevel'] as num).toInt(),
  description: json['description'] as String?,
  trainedWords:
      (json['trainedWords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  stats: json['stats'] == null
      ? const ModelVersionEndpointStats()
      : ModelVersionEndpointStats.fromJson(
          json['stats'] as Map<String, dynamic>,
        ),
  files:
      (json['files'] as List<dynamic>?)
          ?.map((e) => ModelFile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => ModelImage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ModelVersionEndpointDataToJson(
  _ModelVersionEndpointData instance,
) => <String, dynamic>{
  'id': instance.id,
  'modelId': instance.modelId,
  'name': instance.name,
  'baseModel': instance.baseModel,
  'baseModelType': instance.baseModelType,
  'publishedAt': instance.publishedAt.toIso8601String(),
  'nsfwLevel': instance.nsfwLevel,
  'description': instance.description,
  'trainedWords': instance.trainedWords,
  'stats': instance.stats,
  'files': instance.files,
  'images': instance.images,
};
