import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_civitai_box/civitai_api/civitai_api.dart';
import 'package:flutter_civitai_box/services/download/download_magazine_item.dart';
import 'package:flutter_civitai_box/services/download/download_magazine_resolver.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

import 'package:flutter_civitai_box/db/database.dart';
import 'package:flutter_civitai_box/services/download/download_magazine_database.dart';

class MockDio extends Mock implements Dio {}

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/data/magazine/$name').readAsStringSync())
        as Map<String, dynamic>;

CivitaiApiClient _apiWithResponses({
  required Map<String, dynamic> versionJson,
  required Map<String, dynamic> modelJson,
}) {
  final dio = MockDio();
  when(
    () => dio.get(any(), queryParameters: any(named: 'queryParameters')),
  ).thenAnswer((invocation) async {
    final path = invocation.positionalArguments[0] as String;
    if (path.startsWith('model-versions') || path.contains('model-versions')) {
      return Response<dynamic>(
        data: versionJson,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }
    return Response<dynamic>(
      data: modelJson,
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );
  });
  return CivitaiApiClient.withDio(dio);
}

MockDio _mockDioHttpError(int statusCode, String message) {
  final dio = MockDio();
  when(
    () => dio.get(any(), queryParameters: any(named: 'queryParameters')),
  ).thenThrow(
    DioException(
      type: DioExceptionType.badResponse,
      message: message,
      response: Response<dynamic>(
        data: {'error': message},
        statusCode: statusCode,
        requestOptions: RequestOptions(path: ''),
      ),
      requestOptions: RequestOptions(path: ''),
    ),
  );
  return dio;
}

MockDio _mockDioNetworkError() {
  final dio = MockDio();
  when(
    () => dio.get(any(), queryParameters: any(named: 'queryParameters')),
  ).thenThrow(
    DioException(
      type: DioExceptionType.connectionError,
      message: 'Connection refused',
      requestOptions: RequestOptions(path: ''),
    ),
  );
  return dio;
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  const testDbPath = ':memory:';

  setUp(() async {
    await CivitaiDatabase.initForTest(testDbPath);
  });

  tearDown(() async {
    await CivitaiDatabase.instance.then((db) => db.close());
  });

  // =========================================================================
  // load() — happy path
  // =========================================================================
  group('load() — happy path', () {
    test('loads valid version and returns LoadResult.ok', () async {
      final api = _apiWithResponses(
        versionJson: _fixture('model_version_123456.json'),
        modelJson: _fixture('model_789.json'),
      );

      final result = await load(modelVersionId: 123456, api: api);

      expect(result, isA<LoadOk>());
      final item = (result as LoadOk).item;
      expect(item.modelVersionId, 123456);
      expect(item.modelId, 789);
      expect(item.modelName, 'Test Model Name');
      expect(item.versionName, 'v2.0');
      expect(item.baseModel, 'SD 1.5');
      expect(item.modelType, 'Checkpoint');
      expect(item.fileCount, greaterThan(0));
      expect(item.totalSizeKb, greaterThan(0.0));
      expect(item.status, MagazineItemStatus.pending);
    });

    test('persists to database', () async {
      final api = _apiWithResponses(
        versionJson: _fixture('model_version_123456.json'),
        modelJson: _fixture('model_789.json'),
      );

      await load(modelVersionId: 123456, api: api);

      final db = const DownloadMagazineDatabase();
      final rounds = await db.loadAll();
      expect(rounds.length, 1);
      expect(rounds.first.modelVersionId, 123456);
    });

    test('parses display fields correctly', () async {
      final api = _apiWithResponses(
        versionJson: _fixture('model_version_123456.json'),
        modelJson: _fixture('model_789.json'),
      );

      final result = await load(modelVersionId: 123456, api: api);
      final item = (result as LoadOk).item;

      expect(item.fileCount, 4); // 2 model files + 2 images
      expect(item.totalSizeKb, closeTo(10752000.0, 1.0));
      expect(item.modelJson, isNotEmpty);
      expect(item.versionJson, isNotEmpty);
    });

    test('stores full JSON blobs', () async {
      final api = _apiWithResponses(
        versionJson: _fixture('model_version_123456.json'),
        modelJson: _fixture('model_789.json'),
      );

      final result = await load(modelVersionId: 123456, api: api);
      final item = (result as LoadOk).item;

      final parsedModel = jsonDecode(item.modelJson) as Map<String, dynamic>;
      expect(parsedModel['id'], 789);
      expect(parsedModel['name'], 'Test Model Name');

      final parsedVersion =
          jsonDecode(item.versionJson) as Map<String, dynamic>;
      expect(parsedVersion['id'], 123456);
      expect(parsedVersion['modelId'], 789);
    });
  });

  // =========================================================================
  // load() — validation
  // =========================================================================
  group('load() — validation', () {
    test('rejects non-positive version ID', () async {
      final api = _apiWithResponses(
        versionJson: _fixture('model_version_123456.json'),
        modelJson: _fixture('model_789.json'),
      );

      final r0 = await load(modelVersionId: 0, api: api);
      expect(r0, isA<LoadError_>());
      expect((r0 as LoadError_).error.type, LoadErrorType.invalidId);

      final rNeg = await load(modelVersionId: -1, api: api);
      expect((rNeg as LoadError_).error.type, LoadErrorType.invalidId);
    });

    test('rejects version with no downloadable files', () async {
      final api = _apiWithResponses(
        versionJson: _fixture('model_version_no_files.json'),
        modelJson: _fixture('model_789.json'),
      );

      final result = await load(modelVersionId: 555, api: api);
      expect(result, isA<LoadError_>());
      expect((result as LoadError_).error.type, LoadErrorType.validationError);
    });

    test('rejects malformed version JSON (handles parse failure)', () async {
      // When the API returns JSON that freezed can't parse, we should
      // catch it and return an error (not crash).
      final badJson = Map<String, dynamic>.from(
        _fixture('model_version_123456.json'),
      )..remove('modelId');
      final api = _apiWithResponses(
        versionJson: badJson,
        modelJson: _fixture('model_789.json'),
      );

      final result = await load(modelVersionId: 123456, api: api);
      // Freezed parse error is caught as apiError
      expect(result, isA<LoadError_>());
      // Any error type is acceptable — the point is we don't crash
    });

    test('rejects malformed model JSON', () async {
      final badModelJson = Map<String, dynamic>.from(_fixture('model_789.json'))
        ..remove('name');
      final api = _apiWithResponses(
        versionJson: _fixture('model_version_123456.json'),
        modelJson: badModelJson,
      );

      final result = await load(modelVersionId: 123456, api: api);
      expect(result, isA<LoadError_>());
    });
  });

  // =========================================================================
  // load() — API errors
  // =========================================================================
  group('load() — API errors', () {
    test('handles 404 on version endpoint', () async {
      final api = CivitaiApiClient.withDio(_mockDioHttpError(404, 'Not Found'));
      final result = await load(modelVersionId: 999999, api: api);
      expect(result, isA<LoadError_>());
      expect((result as LoadError_).error.type, LoadErrorType.apiError);
    });

    test('handles 403 on version endpoint', () async {
      final api = CivitaiApiClient.withDio(_mockDioHttpError(403, 'Forbidden'));
      final result = await load(modelVersionId: 123456, api: api);
      expect(result, isA<LoadError_>());
      expect((result as LoadError_).error.type, LoadErrorType.apiError);
    });

    test('handles network error', () async {
      final api = CivitaiApiClient.withDio(_mockDioNetworkError());
      final result = await load(modelVersionId: 123456, api: api);
      expect(result, isA<LoadError_>());
      expect((result as LoadError_).error.type, LoadErrorType.networkError);
    });

    test('model endpoint fails after successful version fetch', () async {
      final dio = MockDio();
      var callCount = 0;
      when(
        () => dio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return Response<dynamic>(
            data: _fixture('model_version_123456.json'),
            statusCode: 200,
            requestOptions: RequestOptions(path: 'model-versions/123456'),
          );
        }
        return Response<dynamic>(
          data: {'error': 'Not Found'},
          statusCode: 404,
          requestOptions: RequestOptions(path: 'models/789'),
        );
      });

      final api = CivitaiApiClient.withDio(dio);
      final result = await load(modelVersionId: 123456, api: api);
      expect(result, isA<LoadError_>());

      // Verify nothing persisted on partial failure
      final db = const DownloadMagazineDatabase();
      final rounds = await db.loadAll();
      expect(rounds, isEmpty);
    });
  });

  // =========================================================================
  // load() — deduplication
  // =========================================================================
  group('load() — deduplication', () {
    test('rejects duplicate model_version_id', () async {
      final api = _apiWithResponses(
        versionJson: _fixture('model_version_123456.json'),
        modelJson: _fixture('model_789.json'),
      );

      final r1 = await load(modelVersionId: 123456, api: api);
      expect(r1, isA<LoadOk>());

      final r2 = await load(modelVersionId: 123456, api: api);
      expect(r2, isA<LoadError_>());
      expect((r2 as LoadError_).error.type, LoadErrorType.alreadyInMagazine);
    });
  });

  // =========================================================================
  // fire() — happy path
  // =========================================================================
  group('fire() — happy path', () {
    /// Helper: add a round to the magazine via load().
    Future<void> addRound(int modelVersionId) async {
      final api = _apiWithResponses(
        versionJson: _fixture('model_version_123456.json')
          ..['id'] = modelVersionId,
        modelJson: _fixture('model_789.json'),
      );
      final result = await load(modelVersionId: modelVersionId, api: api);
      expect(result, isA<LoadOk>());
    }

    test('emits done with zeros when magazine is empty', () async {
      final events = await fire(
        magazineDb: const DownloadMagazineDatabase(),
        downloadRound: (item) async => true,
      ).toList();

      expect(events.length, 1);
      expect(events.first, isA<FireDone>());
      final summary = (events.first as FireDone).summary;
      expect(summary.completed, 0);
      expect(summary.skipped, 0);
      expect(summary.failed, 0);
    });

    test('processes one round: roundStarted → roundCompleted → done', () async {
      await addRound(100);
      final db = const DownloadMagazineDatabase();

      final events = await fire(
        magazineDb: db,
        downloadRound: (item) async => true,
      ).toList();

      expect(events.length, 3);
      expect(events[0], isA<FireRoundStarted>());
      expect(events[1], isA<FireRoundCompleted>());
      expect(events[2], isA<FireDone>());

      final done = events[2] as FireDone;
      expect(done.summary.completed, 1);

      // Verify round deleted
      final rounds = await db.loadAll();
      expect(rounds, isEmpty);
    });

    test('processes three rounds sequentially', () async {
      await addRound(100);
      await addRound(200);
      await addRound(300);
      final db = const DownloadMagazineDatabase();

      final events = await fire(
        magazineDb: db,
        downloadRound: (item) async => true,
      ).toList();

      final started = events.whereType<FireRoundStarted>().length;
      final completed = events.whereType<FireRoundCompleted>().length;
      final done = events.whereType<FireDone>();

      expect(started, 3);
      expect(completed, 3);
      expect(done.single.summary.completed, 3);

      // All rounds deleted
      final rounds = await db.loadAll();
      expect(rounds, isEmpty);
    });

    test('processes rounds in insertion order', () async {
      await addRound(100);
      await addRound(200);
      await addRound(300);
      final db = const DownloadMagazineDatabase();

      final orderIds = <int>[];
      await fire(
        magazineDb: db,
        downloadRound: (item) async {
          orderIds.add(item.modelVersionId);
          return true;
        },
      ).toList();

      expect(orderIds, [100, 200, 300]);
    });
  });

  // =========================================================================
  // fire() — retry & jam
  // =========================================================================
  group('fire() — retry & jam', () {
    Future<void> addRound(int modelVersionId) async {
      final api = _apiWithResponses(
        versionJson: _fixture('model_version_123456.json')
          ..['id'] = modelVersionId,
        modelJson: _fixture('model_789.json'),
      );
      await load(modelVersionId: modelVersionId, api: api);
    }

    test('retries up to 3 times then jams', () async {
      await addRound(100);
      final db = const DownloadMagazineDatabase();

      var attempts = 0;
      final events = await fire(
        magazineDb: db,
        downloadRound: (item) async {
          attempts++;
          return false; // Always fail
        },
      ).toList();

      // Should have: started, retrying, retrying, jammed, done (2 retries, 3rd is jam)
      expect(events.whereType<FireRetrying>().length, 2);
      expect(events.whereType<FireJammed>().length, 1);
      expect(attempts, 3);

      // Round should be marked failed, not deleted
      final rounds = await db.loadAll();
      expect(rounds.length, 1);
      expect(rounds.first.status, MagazineItemStatus.failed);
      expect(rounds.first.retryCount, 3);
    });

    test('succeeds on second attempt', () async {
      await addRound(100);
      final db = const DownloadMagazineDatabase();

      var attempts = 0;
      final events = await fire(
        magazineDb: db,
        downloadRound: (item) async {
          attempts++;
          return attempts >= 2; // Fail first, succeed second
        },
      ).toList();

      expect(events.whereType<FireRetrying>().length, 1);
      expect(events.whereType<FireRoundCompleted>().length, 1);
      expect(attempts, 2);
    });

    test('jam stops processing subsequent rounds', () async {
      await addRound(100);
      await addRound(200); // This one should NOT be processed
      final db = const DownloadMagazineDatabase();

      final events = await fire(
        magazineDb: db,
        downloadRound: (item) async => false, // Always fail
      ).toList();

      // Only first round should have been attempted
      final started = events.whereType<FireRoundStarted>();
      expect(started.length, 1);
      expect((started.first).item.modelVersionId, 100);

      // Jammed
      expect(events.whereType<FireJammed>().length, 1);

      // Round 100 is failed, round 200 is still pending
      final rounds = await db.loadAll();
      expect(rounds.length, 2);
      final failed = rounds.firstWhere((r) => r.modelVersionId == 100);
      expect(failed.status, MagazineItemStatus.failed);
      final pending = rounds.firstWhere((r) => r.modelVersionId == 200);
      expect(pending.status, MagazineItemStatus.pending);
    });
  });

  // =========================================================================
  // fire() — unjam
  // =========================================================================
  group('fire() — unjam', () {
    Future<void> addRound(int modelVersionId) async {
      final api = _apiWithResponses(
        versionJson: _fixture('model_version_123456.json')
          ..['id'] = modelVersionId,
        modelJson: _fixture('model_789.json'),
      );
      await load(modelVersionId: modelVersionId, api: api);
    }

    test('skipFailedRound marks as skipped, fire continues', () async {
      await addRound(100);
      await addRound(200);
      final db = const DownloadMagazineDatabase();

      // First fire — round 100 jams
      await fire(magazineDb: db, downloadRound: (item) async => false).toList();

      // Skip the failed round
      final rounds = await db.loadAll();
      final failedId = rounds
          .firstWhere((r) => r.status == MagazineItemStatus.failed)
          .id;
      await db.skipFailedRound(failedId);

      // Fire again — should skip 100 and process 200
      final events = await fire(
        magazineDb: db,
        downloadRound: (item) async => true,
      ).toList();

      final done = events.whereType<FireDone>().single;
      expect(done.summary.completed, 1);
      expect(done.summary.skipped, 1);
    });

    test('retryFailedRound resets and processes successfully', () async {
      await addRound(100);
      final db = const DownloadMagazineDatabase();

      // Jam it
      await fire(magazineDb: db, downloadRound: (item) async => false).toList();

      // Retry the failed round
      final rounds = await db.loadAll();
      final failedId = rounds.first.id;
      await db.retryFailedRound(failedId);

      // Fire again — should succeed this time
      final events = await fire(
        magazineDb: db,
        downloadRound: (item) async => true,
      ).toList();

      expect(events.whereType<FireRoundCompleted>().length, 1);
      final done = events.whereType<FireDone>().single;
      expect(done.summary.completed, 1);
    });
  });
}
