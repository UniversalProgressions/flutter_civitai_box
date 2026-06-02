import 'package:test/test.dart';

import 'package:flutter_civitai_box/civitai_api/civitai_api_exception.dart';

void main() {
  group('CivitaiApiException', () {
    test('creates with statusCode and message', () {
      final error = CivitaiApiException(404, 'Not found');
      expect(error.statusCode, 404);
      expect(error.message, 'Not found');
      expect(error.details, isNull);
    });

    test('creates with optional details', () {
      final error = CivitaiApiException(400, 'Bad request', {'field': 'name'});
      expect(error.details, {'field': 'name'});
    });

    test('toString is readable', () {
      final error = CivitaiApiException(500, 'Server error');
      expect(error.toString(), contains('CivitaiApiException(500)'));
      expect(error.toString(), contains('Server error'));
    });

    test('implements Exception', () {
      final error = CivitaiApiException(404, 'Gone');
      expect(error, isA<Exception>());
    });
  });

  group('CivitaiNetworkException', () {
    test('creates with message', () {
      final error = CivitaiNetworkException('Timeout');
      expect(error.message, 'Timeout');
      expect(error.cause, isNull);
    });

    test('creates with optional cause', () {
      final cause = Exception('boom');
      final error = CivitaiNetworkException('Failed', cause);
      expect(error.cause, cause);
    });

    test('toString is readable', () {
      final error = CivitaiNetworkException('Offline');
      expect(error.toString(), contains('CivitaiNetworkException'));
      expect(error.toString(), contains('Offline'));
    });

    test('implements Exception', () {
      final error = CivitaiNetworkException('Boom');
      expect(error, isA<Exception>());
    });
  });

  group('Catch differentiation', () {
    test('can catch ApiException and NetworkException separately', () async {
      Future<void> throwApi() async =>
          throw const CivitaiApiException(403, 'Forbidden');

      try {
        await throwApi();
        fail('should have thrown');
      } on CivitaiApiException catch (e) {
        expect(e.statusCode, 403);
      } on CivitaiNetworkException catch (_) {
        fail('should not be NetworkException');
      }
    });

    test('can catch NetworkException separately', () async {
      Future<void> throwNet() async =>
          throw const CivitaiNetworkException('DNS error');

      try {
        await throwNet();
        fail('should have thrown');
      } on CivitaiNetworkException catch (e) {
        expect(e.message, 'DNS error');
      } on CivitaiApiException catch (_) {
        fail('should not be ApiException');
      }
    });
  });
}
