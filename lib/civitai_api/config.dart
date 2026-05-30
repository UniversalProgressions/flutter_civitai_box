import 'package:freezed_annotation/freezed_annotation.dart';

part 'config.freezed.dart';
part 'config.g.dart';

/// Configuration for the CivitAI API client.
///
/// ```dart
/// final config = CivitaiConfig(
///   apiKey: 'my-api-key',
///   baseUrl: 'https://civitai.com/api/v1',
/// );
/// ```
@freezed
abstract class CivitaiConfig with _$CivitaiConfig {
  const factory CivitaiConfig({
    @Default('') String apiKey,
    @Default('') String downloadToken,
    @Default('https://civitai.com/api/v1') String baseUrl,
    @Default(30000) int timeout,
    @Default({}) Map<String, String> headers,
    @Default(false) bool validateResponses,
  }) = _CivitaiConfig;

  factory CivitaiConfig.fromJson(Map<String, dynamic> json) =>
      _$CivitaiConfigFromJson(json);
}
