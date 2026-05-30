import 'package:dartz/dartz.dart';
import 'package:test/test.dart';

import 'package:flutter_civitai_box/civitai_api/errors.dart';

void main() {
  group('CivitaiError', () {
    group('ApiError', () {
      test('creates with statusCode and message', () {
        final error = CivitaiError.api(404, 'Not found');
        expect(error, isA<ApiError>());
        expect((error as ApiError).statusCode, 404);
        expect(error.message, 'Not found');
        expect(error.details, isNull);
      });

      test('creates with optional details', () {
        final error = CivitaiError.api(400, 'Bad request', {'field': 'name'});
        expect((error as ApiError).details, {'field': 'name'});
      });

      test('pattern matching via switch works exhaustively', () {
        final error = CivitaiError.api(500, 'Server error');
        final result = switch (error) {
          ApiError(:final statusCode, :final message) =>
            'API $statusCode: $message',
          NetworkError(:final message) => 'Network: $message',
        };
        expect(result, 'API 500: Server error');
      });

      test('copyWith preserves type', () {
        final error = CivitaiError.api(400, 'Bad');
        final copied = (error as ApiError).copyWith(message: 'Worse');
        expect(copied.statusCode, 400);
        expect(copied.message, 'Worse');
      });
    });

    group('NetworkError', () {
      test('creates with message', () {
        final error = CivitaiError.network('Timeout');
        expect(error, isA<NetworkError>());
        expect((error as NetworkError).message, 'Timeout');
        expect(error.cause, isNull);
      });

      test('creates with optional cause', () {
        final cause = Exception('boom');
        final error = CivitaiError.network('Failed', cause);
        expect((error as NetworkError).cause, cause);
      });

      test('pattern matching via switch works exhaustively', () {
        final error = CivitaiError.network('DNS error');
        final result = switch (error) {
          ApiError(:final message) => 'API: $message',
          NetworkError(:final message) => 'Network: $message',
        };
        expect(result, 'Network: DNS error');
      });

      test('copyWith preserves type', () {
        final error = CivitaiError.network('Old');
        final copied = (error as NetworkError).copyWith(message: 'New');
        expect(copied.message, 'New');
      });
    });

    group('Either integration', () {
      test('Left ApiError folds correctly', () {
        final Either<CivitaiError, String> result = left(
          CivitaiError.api(403, 'Forbidden'),
        );
        final output = result.fold(
          (e) => switch (e) {
            ApiError(:final statusCode) => 'status=$statusCode',
            NetworkError() => 'network',
          },
          (v) => v,
        );
        expect(output, 'status=403');
      });

      test('Left NetworkError folds correctly', () {
        final Either<CivitaiError, int> result = left(
          CivitaiError.network('Offline'),
        );
        final output = result.fold(
          (e) => switch (e) {
            ApiError() => 'api',
            NetworkError(:final message) => message,
          },
          (v) => v.toString(),
        );
        expect(output, 'Offline');
      });

      test('toString is readable', () {
        expect(
          CivitaiError.api(404, 'Gone').toString(),
          contains('statusCode: 404'),
        );
        expect(
          CivitaiError.network('Boom').toString(),
          contains('message: Boom'),
        );
      });

      test('equality works', () {
        expect(CivitaiError.api(400, 'x'), CivitaiError.api(400, 'x'));
        expect(CivitaiError.api(400, 'x'), isNot(CivitaiError.api(401, 'x')));
        expect(CivitaiError.network('x'), CivitaiError.network('x'));
        expect(CivitaiError.network('x'), isNot(CivitaiError.api(400, 'x')));
      });
    });
  });
}
