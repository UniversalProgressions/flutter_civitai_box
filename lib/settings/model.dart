/// Immutable application settings value object.
///
/// Mirrors the schema from the bun-civitai-browser settings module:
///
/// | Field             | Req | Description               |
/// |-------------------|-----|---------------------------|
/// | `basePath`        | ✅  | Models folder path        |
/// | `civitaiApiToken` | ✅  | CivitAI API token         |
/// | `httpProxy`       | ❌  | HTTP proxy (optional)     |
final class Settings {
  final String basePath;
  final String civitaiApiToken;
  final String? httpProxy;

  const Settings({
    required this.basePath,
    required this.civitaiApiToken,
    this.httpProxy,
  });

  /// Merge [other] into this instance.
  Settings merge(Map<String, String?> other) {
    return Settings(
      basePath: other['basePath'] ?? basePath,
      civitaiApiToken: other['civitai_api_token'] ?? civitaiApiToken,
      httpProxy: other.containsKey('http_proxy')
          ? other['http_proxy']
          : httpProxy,
    );
  }

  /// Flat map for shared_preferences.
  Map<String, String> toJson() {
    final m = <String, String>{
      'basePath': basePath,
      'civitai_api_token': civitaiApiToken,
    };
    if (httpProxy != null) m['http_proxy'] = httpProxy!;
    return m;
  }

  factory Settings.fromJson(Map<String, String> json) {
    return Settings(
      basePath: json['basePath'] ?? '',
      civitaiApiToken: json['civitai_api_token'] ?? '',
      httpProxy: json['http_proxy'],
    );
  }

  bool get isValid => basePath.isNotEmpty && civitaiApiToken.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Settings &&
          basePath == other.basePath &&
          civitaiApiToken == other.civitaiApiToken &&
          httpProxy == other.httpProxy;

  @override
  int get hashCode => Object.hash(basePath, civitaiApiToken, httpProxy);

  @override
  String toString() =>
      'Settings(basePath: $basePath, civitaiApiToken: ***, '
      'httpProxy: $httpProxy)';
}
