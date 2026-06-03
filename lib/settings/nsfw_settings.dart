import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide NSFW content filter mode.
///
/// Bound to theming: each mode has its own color palette.
enum NsfwFilter {
  /// SFW only — bright, clean, tech-forward theme.
  no,

  /// NSFW only — dark, purple-pink, immersive theme.
  yes,

  /// Show all content — bridge palette (warm-gray + blue-violet).
  all,
}

/// Global, persistent NSFW filter setting.
///
/// Survives app restart via [SharedPreferences]. Notifies listeners
/// when the mode changes, so both the theme and content queries react.
///
/// ```dart
/// final nsfw = await NsfwSettings.getInstance();
/// print(nsfw.mode); // NsfwFilter.all (default)
/// nsfw.mode = NsfwFilter.no; // triggers notifyListeners()
/// ```
class NsfwSettings extends ChangeNotifier {
  final SharedPreferences _prefs;
  NsfwFilter _mode;

  static const _key = 'nsfw_filter';

  NsfwSettings._(this._prefs)
    : _mode = NsfwFilter.values[_prefs.getInt(_key) ?? 2];

  // ---------------------------------------------------------------------------
  // Singleton
  // ---------------------------------------------------------------------------

  static NsfwSettings? instance;

  static Future<NsfwSettings> getInstance() async {
    instance ??= NsfwSettings._(await SharedPreferences.getInstance());
    return instance!;
  }

  /// For testing: inject a pre-built [SharedPreferences].
  static Future<NsfwSettings> initForTest(SharedPreferences prefs) async {
    instance = NsfwSettings._(prefs);
    return instance!;
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  NsfwFilter get mode => _mode;

  set mode(NsfwFilter value) {
    if (_mode == value) return;
    _mode = value;
    _prefs.setInt(_key, value.index);
    notifyListeners();
  }

  /// Convenience: `true` when mode hides NSFW content.
  bool get isSfwOnly => _mode == NsfwFilter.no;

  /// Convenience: `true` when mode hides SFW content.
  bool get isNsfwOnly => _mode == NsfwFilter.yes;
}
