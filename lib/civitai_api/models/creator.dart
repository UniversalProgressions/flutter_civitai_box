import 'package:freezed_annotation/freezed_annotation.dart';

import 'shared.dart';

part 'creator.freezed.dart';
part 'creator.g.dart';

/// A creator (user) on CivitAI.
@freezed
abstract class Creator with _$Creator {
  const factory Creator({
    @Default('') String username,
    int? modelCount,
    String? link,
    String? image,
  }) = _Creator;

  factory Creator.fromJson(Map<String, dynamic> json) =>
      _$CreatorFromJson(json);
}

/// Response from GET /creators.
@freezed
abstract class CreatorsResponse with _$CreatorsResponse {
  const factory CreatorsResponse({
    required List<Creator> items,
    @Default(PaginationMetadata()) PaginationMetadata metadata,
  }) = _CreatorsResponse;

  factory CreatorsResponse.fromJson(Map<String, dynamic> json) =>
      _$CreatorsResponseFromJson(json);
}
