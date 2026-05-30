import 'package:freezed_annotation/freezed_annotation.dart';

import 'creator.dart';
import 'shared.dart';

part 'model.freezed.dart';
part 'model.g.dart';

/// A model version as returned in the models list endpoint.
/// (Images include an id field.)
@freezed
abstract class ModelVersion with _$ModelVersion {
  const factory ModelVersion({
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
    @Default([]) List<ModelImageWithId> images,
  }) = _ModelVersion;

  factory ModelVersion.fromJson(Map<String, dynamic> json) =>
      _$ModelVersionFromJson(json);
}

/// A model as returned in the models list/search endpoint.
@freezed
abstract class Model with _$Model {
  const factory Model({
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
    @Default([]) List<ModelVersion> modelVersions,
  }) = _Model;

  factory Model.fromJson(Map<String, dynamic> json) => _$ModelFromJson(json);
}

/// Response from GET /models.
@freezed
abstract class ModelsResponse with _$ModelsResponse {
  const factory ModelsResponse({
    required List<Model> items,
    @Default(PaginationMetadata()) PaginationMetadata metadata,
  }) = _ModelsResponse;

  factory ModelsResponse.fromJson(Map<String, dynamic> json) =>
      _$ModelsResponseFromJson(json);
}
