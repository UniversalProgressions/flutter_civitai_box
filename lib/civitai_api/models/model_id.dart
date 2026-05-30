import 'package:freezed_annotation/freezed_annotation.dart';

import 'creator.dart';
import 'shared.dart';

part 'model_id.freezed.dart';
part 'model_id.g.dart';

/// A model version as returned by the model-id endpoint.
/// (Images do NOT include an id field.)
@freezed
abstract class ModelByIdVersion with _$ModelByIdVersion {
  const factory ModelByIdVersion({
    required int id,
    required int index,
    required String name,
    required String baseModel,
    String? baseModelType,
    DateTime? publishedAt,
    @Default('Public') String availability,
    required int nsfwLevel,
    String? description,
    @Default([]) List<String> trainedWords,
    @Default(ModelVersionStats()) ModelVersionStats stats,
    @Default([]) List<ModelFile> files,
    @Default([]) List<ModelImage> images,
  }) = _ModelByIdVersion;

  factory ModelByIdVersion.fromJson(Map<String, dynamic> json) =>
      _$ModelByIdVersionFromJson(json);
}

/// A model as returned by GET /models/:id.
@freezed
abstract class ModelById with _$ModelById {
  const factory ModelById({
    required int id,
    required String name,
    String? description,
    @Default('Other') String type,
    @Default(false) bool poi,
    @Default(false) bool nsfw,
    required int nsfwLevel,
    Creator? creator,
    @Default(ModelStats()) ModelStats stats,
    @Default([]) List<String> tags,
    @Default([]) List<ModelByIdVersion> modelVersions,
  }) = _ModelById;

  factory ModelById.fromJson(Map<String, dynamic> json) =>
      _$ModelByIdFromJson(json);
}
