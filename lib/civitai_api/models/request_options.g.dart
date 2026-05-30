// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ModelsRequestOptions _$ModelsRequestOptionsFromJson(
  Map<String, dynamic> json,
) => _ModelsRequestOptions(
  limit: (json['limit'] as num?)?.toInt(),
  page: (json['page'] as num?)?.toInt(),
  query: json['query'] as String?,
  tag: (json['tag'] as List<dynamic>?)?.map((e) => e as String).toList(),
  username: json['username'] as String?,
  types: (json['types'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$ModelTypeEnumMap, e))
      .toList(),
  sort: $enumDecodeNullable(_$ModelsSortEnumMap, json['sort']),
  period: $enumDecodeNullable(_$ModelsPeriodEnumMap, json['period']),
  rating: (json['rating'] as num?)?.toInt(),
  favorites: json['favorites'] as bool?,
  hidden: json['hidden'] as bool?,
  primaryFileOnly: json['primaryFileOnly'] as bool?,
  allowDifferentLicenses: json['allowDifferentLicenses'] as bool?,
  allowCommercialUse: (json['allowCommercialUse'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$AllowCommercialUseEnumMap, e))
      .toList(),
  nsfw: json['nsfw'] as bool?,
  supportsGeneration: json['supportsGeneration'] as bool?,
  checkpointType: $enumDecodeNullable(
    _$CheckpointTypeEnumMap,
    json['checkpointType'],
  ),
  baseModels: (json['baseModels'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$BaseModelEnumMap, e))
      .toList(),
);

Map<String, dynamic> _$ModelsRequestOptionsToJson(
  _ModelsRequestOptions instance,
) => <String, dynamic>{
  'limit': instance.limit,
  'page': instance.page,
  'query': instance.query,
  'tag': instance.tag,
  'username': instance.username,
  'types': instance.types?.map((e) => _$ModelTypeEnumMap[e]!).toList(),
  'sort': _$ModelsSortEnumMap[instance.sort],
  'period': _$ModelsPeriodEnumMap[instance.period],
  'rating': instance.rating,
  'favorites': instance.favorites,
  'hidden': instance.hidden,
  'primaryFileOnly': instance.primaryFileOnly,
  'allowDifferentLicenses': instance.allowDifferentLicenses,
  'allowCommercialUse': instance.allowCommercialUse
      ?.map((e) => _$AllowCommercialUseEnumMap[e]!)
      .toList(),
  'nsfw': instance.nsfw,
  'supportsGeneration': instance.supportsGeneration,
  'checkpointType': _$CheckpointTypeEnumMap[instance.checkpointType],
  'baseModels': instance.baseModels
      ?.map((e) => _$BaseModelEnumMap[e]!)
      .toList(),
};

const _$ModelTypeEnumMap = {
  ModelType.checkpoint: 'checkpoint',
  ModelType.textualInversion: 'textualInversion',
  ModelType.hypernetwork: 'hypernetwork',
  ModelType.aestheticGradient: 'aestheticGradient',
  ModelType.lora: 'lora',
  ModelType.controlnet: 'controlnet',
  ModelType.poses: 'poses',
  ModelType.loCon: 'loCon',
  ModelType.doRA: 'doRA',
  ModelType.other: 'other',
  ModelType.motionModule: 'motionModule',
  ModelType.upscaler: 'upscaler',
  ModelType.vae: 'vae',
  ModelType.wildcards: 'wildcards',
  ModelType.workflows: 'workflows',
  ModelType.detection: 'detection',
};

const _$ModelsSortEnumMap = {
  ModelsSort.highestRated: 'highestRated',
  ModelsSort.mostDownloaded: 'mostDownloaded',
  ModelsSort.newest: 'newest',
};

const _$ModelsPeriodEnumMap = {
  ModelsPeriod.allTime: 'allTime',
  ModelsPeriod.day: 'day',
  ModelsPeriod.week: 'week',
  ModelsPeriod.month: 'month',
  ModelsPeriod.year: 'year',
};

const _$AllowCommercialUseEnumMap = {
  AllowCommercialUse.image: 'image',
  AllowCommercialUse.rentCivit: 'rentCivit',
  AllowCommercialUse.rent: 'rent',
  AllowCommercialUse.sell: 'sell',
  AllowCommercialUse.none: 'none',
};

const _$CheckpointTypeEnumMap = {
  CheckpointType.merge: 'merge',
  CheckpointType.trained: 'trained',
};

const _$BaseModelEnumMap = {
  BaseModel.auraFlow: 'auraFlow',
  BaseModel.cogVideoX: 'cogVideoX',
  BaseModel.flux1D: 'flux1D',
  BaseModel.flux1S: 'flux1S',
  BaseModel.hiDream: 'hiDream',
  BaseModel.hunyuan1: 'hunyuan1',
  BaseModel.hunyuanVideo: 'hunyuanVideo',
  BaseModel.illustrious: 'illustrious',
  BaseModel.kolors: 'kolors',
  BaseModel.ltxv: 'ltxv',
  BaseModel.lumina: 'lumina',
  BaseModel.mochi: 'mochi',
  BaseModel.noobAI: 'noobAI',
  BaseModel.odor: 'odor',
  BaseModel.openAI: 'openAI',
  BaseModel.other: 'other',
  BaseModel.pixArtE: 'pixArtE',
  BaseModel.pixArtA: 'pixArtA',
  BaseModel.playgroundV2: 'playgroundV2',
  BaseModel.pony: 'pony',
  BaseModel.sd14: 'sd14',
  BaseModel.sd15: 'sd15',
  BaseModel.sd15Hyper: 'sd15Hyper',
  BaseModel.sd15LCM: 'sd15LCM',
  BaseModel.sd20: 'sd20',
  BaseModel.sd20768: 'sd20768',
  BaseModel.sd21: 'sd21',
  BaseModel.sd21768: 'sd21768',
  BaseModel.sd21Unclip: 'sd21Unclip',
  BaseModel.sd3: 'sd3',
  BaseModel.sd35: 'sd35',
  BaseModel.sd35Large: 'sd35Large',
  BaseModel.sd35LargeTurbo: 'sd35LargeTurbo',
  BaseModel.sd35Medium: 'sd35Medium',
  BaseModel.sdxl09: 'sdxl09',
  BaseModel.sdxl10: 'sdxl10',
  BaseModel.sdxl10LCM: 'sdxl10LCM',
  BaseModel.sdxlDistilled: 'sdxlDistilled',
  BaseModel.sdxlHyper: 'sdxlHyper',
  BaseModel.sdxlLightning: 'sdxlLightning',
  BaseModel.sdxlTurbo: 'sdxlTurbo',
  BaseModel.svd: 'svd',
  BaseModel.svdXT: 'svdXT',
  BaseModel.stableCascade: 'stableCascade',
  BaseModel.wanVideo: 'wanVideo',
};

_CreatorsRequestOptions _$CreatorsRequestOptionsFromJson(
  Map<String, dynamic> json,
) => _CreatorsRequestOptions(
  limit: (json['limit'] as num?)?.toInt(),
  query: json['query'] as String?,
);

Map<String, dynamic> _$CreatorsRequestOptionsToJson(
  _CreatorsRequestOptions instance,
) => <String, dynamic>{'limit': instance.limit, 'query': instance.query};

_TagsRequestOptions _$TagsRequestOptionsFromJson(Map<String, dynamic> json) =>
    _TagsRequestOptions(
      limit: (json['limit'] as num?)?.toInt(),
      query: json['query'] as String?,
    );

Map<String, dynamic> _$TagsRequestOptionsToJson(_TagsRequestOptions instance) =>
    <String, dynamic>{'limit': instance.limit, 'query': instance.query};
