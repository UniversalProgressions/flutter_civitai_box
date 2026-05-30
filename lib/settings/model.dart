/// Immutable application settings value object.
///
/// Mirrors the schema from the bun-civitai-browser settings module:
///
/// | Field             | Req | Description               |
/// |-------------------|-----|---------------------------|
/// | `basePath`        | ✅  | Models folder path        |
/// | `civitaiApiToken` | ✅  | CivitAI API token         |
/// | `gopeedApiHost`   | ✅  | Gopeed downloader host    |
/// | `httpProxy`       | ❌  | HTTP proxy (optional)     |
/// | `gopeedApiToken`  | ❌  | Gopeed API token (opt.)   |
final class Settings {
  final String basePath;
  final String civitaiApiToken;
  final String gopeedApiHost;
  final String? httpProxy;
  final String? gopeedApiToken;

  const Settings({
    required this.basePath,
    required this.civitaiApiToken,
    required this.gopeedApiHost,
    this.httpProxy,
    this.gopeedApiToken,
  });

  /// Merge [other] into this instance.
  Settings merge(Map<String, String?> other) {
    return Settings(
      basePath: other['basePath'] ?? basePath,
      civitaiApiToken: other['civitai_api_token'] ?? civitaiApiToken,
      gopeedApiHost: other['gopeed_api_host'] ?? gopeedApiHost,
      httpProxy: other.containsKey('http_proxy')
          ? other['http_proxy']
          : httpProxy,
      gopeedApiToken: other.containsKey('gopeed_api_token')
          ? other['gopeed_api_token']
          : gopeedApiToken,
    );
  }

  /// Flat map for shared_preferences.
  Map<String, String> toJson() {
    final m = <String, String>{
      'basePath': basePath,
      'civitai_api_token': civitaiApiToken,
      'gopeed_api_host': gopeedApiHost,
    };
    if (httpProxy != null) m['http_proxy'] = httpProxy!;
    if (gopeedApiToken != null) m['gopeed_api_token'] = gopeedApiToken!;
    return m;
  }

  factory Settings.fromJson(Map<String, String> json) {
    return Settings(
      basePath: json['basePath'] ?? '',
      civitaiApiToken: json['civitai_api_token'] ?? '',
      gopeedApiHost: json['gopeed_api_host'] ?? '',
      httpProxy: json['http_proxy'],
      gopeedApiToken: json['gopeed_api_token'],
    );
  }

  bool get isValid =>
      basePath.isNotEmpty &&
      civitaiApiToken.isNotEmpty &&
      gopeedApiHost.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Settings &&
          basePath == other.basePath &&
          civitaiApiToken == other.civitaiApiToken &&
          gopeedApiHost == other.gopeedApiHost &&
          httpProxy == other.httpProxy &&
          gopeedApiToken == other.gopeedApiToken;

  @override
  int get hashCode => Object.hash(
    basePath,
    civitaiApiToken,
    gopeedApiHost,
    httpProxy,
    gopeedApiToken,
  );

  @override
  String toString() =>
      'Settings(basePath: $basePath, civitaiApiToken: ***, '
      'gopeedApiHost: $gopeedApiHost, httpProxy: $httpProxy, '
      'gopeedApiToken: ${gopeedApiToken != null ? '***' : 'null'})';
}
