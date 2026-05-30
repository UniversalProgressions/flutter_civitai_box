// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CivitaiConfig _$CivitaiConfigFromJson(Map<String, dynamic> json) =>
    _CivitaiConfig(
      apiKey: json['apiKey'] as String? ?? '',
      downloadToken: json['downloadToken'] as String? ?? '',
      baseUrl: json['baseUrl'] as String? ?? 'https://civitai.com/api/v1',
      timeout: (json['timeout'] as num?)?.toInt() ?? 30000,
      headers:
          (json['headers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      validateResponses: json['validateResponses'] as bool? ?? false,
    );

Map<String, dynamic> _$CivitaiConfigToJson(_CivitaiConfig instance) =>
    <String, dynamic>{
      'apiKey': instance.apiKey,
      'downloadToken': instance.downloadToken,
      'baseUrl': instance.baseUrl,
      'timeout': instance.timeout,
      'headers': instance.headers,
      'validateResponses': instance.validateResponses,
    };
