/// Errors thrown by the settings module.
library;

sealed class SettingsError implements Exception {
  final String message;
  const SettingsError(this.message);

  @override
  String toString() => message;
}

final class SettingsNotConfiguredError extends SettingsError {
  const SettingsNotConfiguredError()
    : super('Settings not configured — required fields are missing.');
}

final class SettingsValidationError extends SettingsError {
  final String summary;
  const SettingsValidationError(this.summary)
    : super('Settings validation failed: $summary');
}

final class SettingsUpdateError extends SettingsError {
  final String summary;
  const SettingsUpdateError(this.summary)
    : super('Settings update validation failed: $summary');
}
