import 'package:shared_preferences/shared_preferences.dart';

import 'errors.dart';
import 'model.dart';

/// Manages application settings backed by [SharedPreferences].
///
/// ```dart
/// final service = await SettingsService.getInstance();
/// if (service.hasSettings) print(service.settings.basePath);
/// ```
final class SettingsService {
  final SharedPreferences _prefs;

  SettingsService._(this._prefs);

  // ---------------------------------------------------------------------------
  // Singleton
  // ---------------------------------------------------------------------------

  static SettingsService? _instance;

  static Future<SettingsService> getInstance() async {
    _instance ??= SettingsService._(await SharedPreferences.getInstance());
    return _instance!;
  }

  /// For testing: inject a pre-built [SharedPreferences].
  static Future<SettingsService> initForTest(SharedPreferences prefs) async {
    _instance = SettingsService._(prefs);
    return _instance!;
  }

  // ---------------------------------------------------------------------------
  // Storage keys (match the old project's JSON field names)
  // ---------------------------------------------------------------------------

  static const _keys = ['basePath', 'civitai_api_token', 'http_proxy'];

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  Settings get settings {
    final s = _read();
    if (!s.isValid) throw const SettingsNotConfiguredError();
    return s;
  }

  Settings? get settingsOrNull {
    final s = _read();
    return s.isValid ? s : null;
  }

  bool get hasSettings => _read().isValid;

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  /// Merge [partial] into current settings and persist.
  /// Throws [SettingsUpdateError] if required fields are missing.
  Settings updateSettings(Map<String, String?> partial) {
    final updated = _read().merge(partial);

    final missing = <String>[];
    if (updated.basePath.isEmpty) missing.add('basePath');
    if (updated.civitaiApiToken.isEmpty) missing.add('civitaiApiToken');
    if (missing.isNotEmpty) {
      throw SettingsUpdateError(
        'Missing required fields: ${missing.join(', ')}',
      );
    }

    final json = updated.toJson();
    for (final e in json.entries) {
      _prefs.setString(e.key, e.value);
    }
    // Remove optional keys that were cleared
    for (final key in _keys) {
      if (!json.containsKey(key)) _prefs.remove(key);
    }

    return updated;
  }

  Future<void> resetSettings() async {
    for (final key in _keys) {
      await _prefs.remove(key);
    }
  }

  /// Validate [data] without persisting.
  Settings validateSettings(Map<String, String> data) {
    final s = Settings.fromJson(data);
    if (!s.isValid) {
      throw SettingsValidationError('Missing one or more required fields');
    }
    return s;
  }

  bool isValid() => hasSettings;

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  Settings _read() {
    final map = <String, String>{};
    for (final key in _keys) {
      final v = _prefs.getString(key);
      if (v != null) map[key] = v;
    }
    return Settings.fromJson(map);
  }
}
