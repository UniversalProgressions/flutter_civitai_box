import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'request_options.freezed.dart';
part 'request_options.g.dart';

/// Request options for GET /models.
@freezed
abstract class ModelsRequestOptions with _$ModelsRequestOptions {
  const factory ModelsRequestOptions({
    /// Results per page (1–100).
    int? limit,

    /// Page number (cannot be used with query search — use cursor-based).
    int? page,

    /// Search query to filter models by name.
    String? query,

    /// Filter by tag(s).
    List<String>? tag,

    /// Filter by creator username.
    String? username,

    /// Filter by model type(s).
    List<ModelType>? types,

    /// Sort order.
    ModelsSort? sort,

    /// Time period for sorting.
    ModelsPeriod? period,

    /// Filter by rating.
    int? rating,

    /// (AUTHED) Filter to favorites.
    bool? favorites,

    /// (AUTHED) Filter to hidden models.
    bool? hidden,

    /// Only include primary file per model.
    bool? primaryFileOnly,

    /// Filter by license derivatives.
    bool? allowDifferentLicenses,

    /// Filter by commercial use permissions.
    List<AllowCommercialUse>? allowCommercialUse,

    /// If false, return safer images and hide models without safe images.
    bool? nsfw,

    /// If true, only return models that support generation.
    bool? supportsGeneration,

    /// Filter by checkpoint type.
    CheckpointType? checkpointType,

    /// Filter by base model(s).
    List<BaseModel>? baseModels,
  }) = _ModelsRequestOptions;

  factory ModelsRequestOptions.fromJson(Map<String, dynamic> json) =>
      _$ModelsRequestOptionsFromJson(json);
}

/// Request options for GET /creators.
@freezed
abstract class CreatorsRequestOptions with _$CreatorsRequestOptions {
  const factory CreatorsRequestOptions({int? limit, String? query}) =
      _CreatorsRequestOptions;

  factory CreatorsRequestOptions.fromJson(Map<String, dynamic> json) =>
      _$CreatorsRequestOptionsFromJson(json);
}

/// Request options for GET /tags.
@freezed
abstract class TagsRequestOptions with _$TagsRequestOptions {
  const factory TagsRequestOptions({int? limit, String? query}) =
      _TagsRequestOptions;

  factory TagsRequestOptions.fromJson(Map<String, dynamic> json) =>
      _$TagsRequestOptionsFromJson(json);
}
