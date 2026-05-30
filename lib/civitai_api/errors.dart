import 'package:freezed_annotation/freezed_annotation.dart';

part 'errors.freezed.dart';

/// Simplified error type for CivitAI API interactions.
///
/// Uses Freezed sealed union for exhaustive pattern matching:
/// ```dart
/// result.fold(
///   (error) => switch (error) {
///     ApiError(:final statusCode, :final message) => ...,
///     NetworkError(:final message) => ...,
///   },
///   (data) => ...,
/// );
/// ```
@freezed
sealed class CivitaiError with _$CivitaiError {
  /// Server returned an error response (4xx, 5xx).
  const factory CivitaiError.api(
    int statusCode,
    String message, [
    Map<String, dynamic>? details,
  ]) = ApiError;

  /// Network-level failure (timeout, DNS, connection refused, etc).
  const factory CivitaiError.network(String message, [Object? cause]) =
      NetworkError;
}
