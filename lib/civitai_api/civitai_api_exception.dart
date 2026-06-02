/// Thrown when the CivitAI API returns an error response (4xx, 5xx).
class CivitaiApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? details;

  const CivitaiApiException(this.statusCode, this.message, [this.details]);

  @override
  String toString() => 'CivitaiApiException($statusCode): $message';
}

/// Thrown when a network-level failure occurs (timeout, DNS, connection refused, etc.).
class CivitaiNetworkException implements Exception {
  final String message;
  final Object? cause;

  const CivitaiNetworkException(this.message, [this.cause]);

  @override
  String toString() => 'CivitaiNetworkException: $message';
}
