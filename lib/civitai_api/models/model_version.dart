import 'package:freezed_annotation/freezed_annotation.dart';

import 'shared.dart';

part 'model_version.freezed.dart';
part 'model_version.g.dart';

/// A specific model version as returned by GET /model-versions/:id.
/// Note: stats structure differs from the models endpoint (no thumbsDownCount).
@freezed
abstract class ModelVersionEndpointData with _$ModelVersionEndpointData {
  const factory ModelVersionEndpointData({
    required int id,
    required int modelId,
    required String name,
    required String baseModel,
    String? baseModelType,
    required DateTime publishedAt,
    required int nsfwLevel,
    String? description,
    @Default([]) List<String> trainedWords,
    @Default(ModelVersionEndpointStats()) ModelVersionEndpointStats stats,
    @Default([]) List<ModelFile> files,
    @Default([]) List<ModelImage> images,
  }) = _ModelVersionEndpointData;

  factory ModelVersionEndpointData.fromJson(Map<String, dynamic> json) =>
      _$ModelVersionEndpointDataFromJson(json);
}
