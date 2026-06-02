// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FileHashes _$FileHashesFromJson(Map<String, dynamic> json) => _FileHashes(
  sha256: json['sha256'] as String?,
  crc32: json['crc32'] as String?,
  blake3: json['blake3'] as String?,
  autoV3: json['autoV3'] as String?,
  autoV2: json['autoV2'] as String?,
  autoV1: json['autoV1'] as String?,
);

Map<String, dynamic> _$FileHashesToJson(_FileHashes instance) =>
    <String, dynamic>{
      'sha256': instance.sha256,
      'crc32': instance.crc32,
      'blake3': instance.blake3,
      'autoV3': instance.autoV3,
      'autoV2': instance.autoV2,
      'autoV1': instance.autoV1,
    };

_FileMetadata _$FileMetadataFromJson(Map<String, dynamic> json) =>
    _FileMetadata(
      fp: json['fp'] as String?,
      size: json['size'] as String?,
      format: json['format'] as String?,
    );

Map<String, dynamic> _$FileMetadataToJson(_FileMetadata instance) =>
    <String, dynamic>{
      'fp': instance.fp,
      'size': instance.size,
      'format': instance.format,
    };

_ModelFile _$ModelFileFromJson(Map<String, dynamic> json) => _ModelFile(
  id: (json['id'] as num).toInt(),
  sizeKB: (json['sizeKB'] as num).toDouble(),
  name: json['name'] as String,
  type: json['type'] as String,
  metadata: json['metadata'] == null
      ? const FileMetadata()
      : FileMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
  scannedAt: json['scannedAt'] == null
      ? null
      : DateTime.parse(json['scannedAt'] as String),
  hashes: json['hashes'] == null
      ? null
      : FileHashes.fromJson(json['hashes'] as Map<String, dynamic>),
  downloadUrl: json['downloadUrl'] as String,
);

Map<String, dynamic> _$ModelFileToJson(_ModelFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sizeKB': instance.sizeKB,
      'name': instance.name,
      'type': instance.type,
      'metadata': instance.metadata,
      'scannedAt': instance.scannedAt?.toIso8601String(),
      'hashes': instance.hashes,
      'downloadUrl': instance.downloadUrl,
    };

_ModelImage _$ModelImageFromJson(Map<String, dynamic> json) => _ModelImage(
  url: json['url'] as String,
  nsfwLevel: (json['nsfwLevel'] as num).toInt(),
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
  hash: json['hash'] as String?,
  type: json['type'] as String?,
);

Map<String, dynamic> _$ModelImageToJson(_ModelImage instance) =>
    <String, dynamic>{
      'url': instance.url,
      'nsfwLevel': instance.nsfwLevel,
      'width': instance.width,
      'height': instance.height,
      'hash': instance.hash,
      'type': instance.type,
    };

_ModelImageWithId _$ModelImageWithIdFromJson(Map<String, dynamic> json) =>
    _ModelImageWithId(
      id: (json['id'] as num).toInt(),
      url: json['url'] as String,
      nsfwLevel: (json['nsfwLevel'] as num).toInt(),
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      hash: json['hash'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$ModelImageWithIdToJson(_ModelImageWithId instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'nsfwLevel': instance.nsfwLevel,
      'width': instance.width,
      'height': instance.height,
      'hash': instance.hash,
      'type': instance.type,
    };

_ModelVersionStats _$ModelVersionStatsFromJson(Map<String, dynamic> json) =>
    _ModelVersionStats(
      downloadCount: (json['downloadCount'] as num?)?.toInt() ?? 0,
      ratingCount: (json['ratingCount'] as num?)?.toInt(),
      rating: (json['rating'] as num?)?.toDouble(),
      thumbsUpCount: (json['thumbsUpCount'] as num?)?.toInt() ?? 0,
      thumbsDownCount: (json['thumbsDownCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ModelVersionStatsToJson(_ModelVersionStats instance) =>
    <String, dynamic>{
      'downloadCount': instance.downloadCount,
      'ratingCount': instance.ratingCount,
      'rating': instance.rating,
      'thumbsUpCount': instance.thumbsUpCount,
      'thumbsDownCount': instance.thumbsDownCount,
    };

_ModelVersionEndpointStats _$ModelVersionEndpointStatsFromJson(
  Map<String, dynamic> json,
) => _ModelVersionEndpointStats(
  downloadCount: (json['downloadCount'] as num?)?.toInt() ?? 0,
  ratingCount: (json['ratingCount'] as num?)?.toInt(),
  rating: (json['rating'] as num?)?.toDouble(),
  thumbsUpCount: (json['thumbsUpCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ModelVersionEndpointStatsToJson(
  _ModelVersionEndpointStats instance,
) => <String, dynamic>{
  'downloadCount': instance.downloadCount,
  'ratingCount': instance.ratingCount,
  'rating': instance.rating,
  'thumbsUpCount': instance.thumbsUpCount,
};

_ModelStats _$ModelStatsFromJson(Map<String, dynamic> json) => _ModelStats(
  downloadCount: (json['downloadCount'] as num?)?.toInt() ?? 0,
  favoriteCount: (json['favoriteCount'] as num?)?.toInt(),
  thumbsUpCount: (json['thumbsUpCount'] as num?)?.toInt() ?? 0,
  thumbsDownCount: (json['thumbsDownCount'] as num?)?.toInt(),
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  ratingCount: (json['ratingCount'] as num?)?.toInt(),
  rating: (json['rating'] as num?)?.toDouble(),
  tippedAmountCount: (json['tippedAmountCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ModelStatsToJson(_ModelStats instance) =>
    <String, dynamic>{
      'downloadCount': instance.downloadCount,
      'favoriteCount': instance.favoriteCount,
      'thumbsUpCount': instance.thumbsUpCount,
      'thumbsDownCount': instance.thumbsDownCount,
      'commentCount': instance.commentCount,
      'ratingCount': instance.ratingCount,
      'rating': instance.rating,
      'tippedAmountCount': instance.tippedAmountCount,
    };

_PaginationMetadata _$PaginationMetadataFromJson(Map<String, dynamic> json) =>
    _PaginationMetadata(
      totalItems: (json['totalItems'] as num?)?.toInt(),
      currentPage: (json['currentPage'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
      nextPage: json['nextPage'] as String?,
      prevPage: json['prevPage'] as String?,
    );

Map<String, dynamic> _$PaginationMetadataToJson(_PaginationMetadata instance) =>
    <String, dynamic>{
      'totalItems': instance.totalItems,
      'currentPage': instance.currentPage,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
      'nextPage': instance.nextPage,
      'prevPage': instance.prevPage,
    };
