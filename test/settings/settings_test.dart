import 'package:flutter_civitai_box/settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Settings model', () {
    test('isValid returns false when required fields are empty', () {
      const s = Settings(basePath: '', civitaiApiToken: '');
      expect(s.isValid, false);
    });

    test('isValid returns true when all required fields present', () {
      const s = Settings(basePath: '/models', civitaiApiToken: 'tok');
      expect(s.isValid, true);
    });

    test('merge overwrites provided keys and keeps others', () {
      const original = Settings(
        basePath: '/old',
        civitaiApiToken: 'old-tok',
        httpProxy: 'http://proxy',
      );
      final merged = original.merge({'basePath': '/new', 'http_proxy': null});
      expect(merged.basePath, '/new');
      expect(merged.civitaiApiToken, 'old-tok');
      expect(merged.httpProxy, isNull);
    });

    test('toJson / fromJson round-trip', () {
      const original = Settings(
        basePath: '/m',
        civitaiApiToken: 'abc',
        httpProxy: 'http://p',
      );
      final json = original.toJson();
      final restored = Settings.fromJson(json);
      expect(restored, original);
    });

    test('toJson omits null optionals', () {
      const s = Settings(basePath: '/m', civitaiApiToken: 'abc');
      final json = s.toJson();
      expect(json.containsKey('http_proxy'), false);
    });
  });

  group('SettingsService — unconfigured', () {
    test('hasSettings returns false initially', () async {
      final svc = await SettingsService.getInstance();
      expect(svc.hasSettings, false);
    });

    test('settings throws SettingsNotConfiguredError', () async {
      final svc = await SettingsService.getInstance();
      expect(() => svc.settings, throwsA(isA<SettingsNotConfiguredError>()));
    });

    test('settingsOrNull returns null', () async {
      final svc = await SettingsService.getInstance();
      expect(svc.settingsOrNull, isNull);
    });

    test('isValid returns false', () async {
      final svc = await SettingsService.getInstance();
      expect(svc.isValid(), false);
    });
  });

  group('SettingsService — configured', () {
    setUp(() async {
      final svc = await SettingsService.getInstance();
      svc.updateSettings({
        'basePath': '/models',
        'civitai_api_token': 'tok123',
        'http_proxy': 'http://proxy:3128',
      });
    });

    test('hasSettings returns true', () async {
      final svc = await SettingsService.getInstance();
      expect(svc.hasSettings, true);
    });

    test('settings returns full object', () async {
      final svc = await SettingsService.getInstance();
      final s = svc.settings;
      expect(s.basePath, '/models');
      expect(s.civitaiApiToken, 'tok123');
      expect(s.httpProxy, 'http://proxy:3128');
    });

    test('partial update preserves other fields', () async {
      final svc = await SettingsService.getInstance();
      svc.updateSettings({'basePath': '/newpath'});
      final s = svc.settings;
      expect(s.basePath, '/newpath');
      expect(s.civitaiApiToken, 'tok123');
    });

    test('resetSettings clears everything', () async {
      final svc = await SettingsService.getInstance();
      await svc.resetSettings();
      expect(svc.hasSettings, false);
    });
  });

  group('SettingsService — validation', () {
    test('updateSettings throws when required field missing', () async {
      final svc = await SettingsService.getInstance();
      expect(
        () => svc.updateSettings({'basePath': '/m'}),
        throwsA(isA<SettingsUpdateError>()),
      );
    });

    test('validateSettings throws when invalid', () async {
      final svc = await SettingsService.getInstance();
      expect(
        () => svc.validateSettings({'basePath': ''}),
        throwsA(isA<SettingsValidationError>()),
      );
    });

    test('validateSettings returns Settings when valid', () async {
      final svc = await SettingsService.getInstance();
      final s = svc.validateSettings({
        'basePath': '/m',
        'civitai_api_token': 'tok',
      });
      expect(s.isValid, true);
    });
  });

  group('Edge cases', () {
    test('toString hides tokens', () {
      const s = Settings(basePath: '/m', civitaiApiToken: 'secret123');
      final str = s.toString();
      expect(str.contains('secret123'), false);
      expect(str.contains('***'), true);
    });
  });
}
