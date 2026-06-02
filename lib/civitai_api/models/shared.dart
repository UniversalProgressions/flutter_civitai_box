import 'package:freezed_annotation/freezed_annotation.dart';

part 'shared.freezed.dart';
part 'shared.g.dart';

/// File hash values.
@freezed
abstract class FileHashes with _$FileHashes {
  const factory FileHashes({
    String? sha256,
    String? crc32,
    String? blake3,
    String? autoV3,
    String? autoV2,
    String? autoV1,
  }) = _FileHashes;

  factory FileHashes.fromJson(Map<String, dynamic> json) =>
      _$FileHashesFromJson(json);
}

/// Model file metadata (fp, size, format).
@freezed
abstract class FileMetadata with _$FileMetadata {
  const factory FileMetadata({String? fp, String? size, String? format}) =
      _FileMetadata;

  factory FileMetadata.fromJson(Map<String, dynamic> json) =>
      _$FileMetadataFromJson(json);
}

/// A downloadable file within a model version.
@freezed
abstract class ModelFile with _$ModelFile {
  const factory ModelFile({
    required int id,
    required double sizeKB,
    required String name,
    required String type,
    @Default(FileMetadata()) FileMetadata metadata,
    DateTime? scannedAt,
    FileHashes? hashes,
    required String downloadUrl,
  }) = _ModelFile;

  factory ModelFile.fromJson(Map<String, dynamic> json) =>
      _$ModelFileFromJson(json);
}

/// An image attached to a model or version (without id field).
@freezed
abstract class ModelImage with _$ModelImage {
  const factory ModelImage({
    required String url,
    required int nsfwLevel,
    required int width,
    required int height,
    String? hash,
    String? type,
  }) = _ModelImage;

  factory ModelImage.fromJson(Map<String, dynamic> json) =>
      _$ModelImageFromJson(json);
}

/// An image with an id field (used in the models list endpoint).
@freezed
abstract class ModelImageWithId with _$ModelImageWithId {
  const factory ModelImageWithId({
    required int id,
    required String url,
    required int nsfwLevel,
    required int width,
    required int height,
    required String hash,
    required String type,
  }) = _ModelImageWithId;

  factory ModelImageWithId.fromJson(Map<String, dynamic> json) =>
      _$ModelImageWithIdFromJson(json);
}

/// Statistics for a single model version.
@freezed
abstract class ModelVersionStats with _$ModelVersionStats {
  const factory ModelVersionStats({
    @Default(0) int downloadCount,
    int? ratingCount,
    double? rating,
    @Default(0) int thumbsUpCount,
    @Default(0) int thumbsDownCount,
  }) = _ModelVersionStats;

  factory ModelVersionStats.fromJson(Map<String, dynamic> json) =>
      _$ModelVersionStatsFromJson(json);
}

/// Statistics for the model-version endpoint (no thumbsDownCount).
@freezed
abstract class ModelVersionEndpointStats with _$ModelVersionEndpointStats {
  const factory ModelVersionEndpointStats({
    @Default(0) int downloadCount,
    int? ratingCount,
    double? rating,
    @Default(0) int thumbsUpCount,
  }) = _ModelVersionEndpointStats;

  factory ModelVersionEndpointStats.fromJson(Map<String, dynamic> json) =>
      _$ModelVersionEndpointStatsFromJson(json);
}

/// Statistics for a model.
@freezed
abstract class ModelStats with _$ModelStats {
  const factory ModelStats({
    @Default(0) int downloadCount,
    int? favoriteCount,
    @Default(0) int thumbsUpCount,
    int? thumbsDownCount,
    @Default(0) int commentCount,
    int? ratingCount,
    double? rating,
    @Default(0) int tippedAmountCount,
  }) = _ModelStats;

  factory ModelStats.fromJson(Map<String, dynamic> json) =>
      _$ModelStatsFromJson(json);
}

/// Pagination metadata returned with list responses.
@freezed
abstract class PaginationMetadata with _$PaginationMetadata {
  const factory PaginationMetadata({
    int? totalItems,
    int? currentPage,
    int? pageSize,
    int? totalPages,
    String? nextPage,
    String? prevPage,
  }) = _PaginationMetadata;

  factory PaginationMetadata.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetadataFromJson(json);
}
