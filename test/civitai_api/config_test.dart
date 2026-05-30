import 'package:test/test.dart';

import 'package:flutter_civitai_box/civitai_api/config.dart';

void main() {
  group('CivitaiConfig', () {
    test('defaults are correct', () {
      final config = CivitaiConfig();
      expect(config.apiKey, '');
      expect(config.downloadToken, '');
      expect(config.baseUrl, 'https://civitai.com/api/v1');
      expect(config.timeout, 30000);
      expect(config.headers, {});
      expect(config.validateResponses, false);
    });

    test('custom values override defaults', () {
      final config = CivitaiConfig(
        apiKey: 'key-123',
        baseUrl: 'https://custom.api/v1',
        timeout: 5000,
        validateResponses: true,
      );
      expect(config.apiKey, 'key-123');
      expect(config.baseUrl, 'https://custom.api/v1');
      expect(config.timeout, 5000);
      expect(config.validateResponses, true);
    });

    test('copyWith works', () {
      final config = CivitaiConfig(apiKey: 'old');
      final updated = config.copyWith(apiKey: 'new');
      expect(updated.apiKey, 'new');
      expect(config.apiKey, 'old'); // original unchanged
    });

    test('equality works', () {
      expect(CivitaiConfig(apiKey: 'a'), CivitaiConfig(apiKey: 'a'));
      expect(CivitaiConfig(apiKey: 'a'), isNot(CivitaiConfig(apiKey: 'b')));
    });

    group('fromJson / toJson', () {
      test('fromJson with all fields', () {
        final json = {
          'apiKey': 'test-key',
          'downloadToken': 'dl-token',
          'baseUrl': 'https://example.com/api',
          'timeout': 10000,
          'headers': {'X-Custom': 'value'},
          'validateResponses': true,
        };
        final config = CivitaiConfig.fromJson(json);
        expect(config.apiKey, 'test-key');
        expect(config.downloadToken, 'dl-token');
        expect(config.baseUrl, 'https://example.com/api');
        expect(config.timeout, 10000);
        expect(config.headers, {'X-Custom': 'value'});
        expect(config.validateResponses, true);
      });

      test('fromJson with missing fields uses defaults', () {
        final config = CivitaiConfig.fromJson({});
        expect(config.apiKey, '');
        expect(config.baseUrl, 'https://civitai.com/api/v1');
        expect(config.timeout, 30000);
      });

      test('toJson roundtrip', () {
        final original = CivitaiConfig(
          apiKey: 'k',
          timeout: 9999,
          headers: {'H': 'V'},
        );
        final json = original.toJson();
        final restored = CivitaiConfig.fromJson(json);
        expect(restored.apiKey, original.apiKey);
        expect(restored.timeout, original.timeout);
        expect(restored.headers, original.headers);
      });
    });
  });
}
