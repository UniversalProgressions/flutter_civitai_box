import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../database.dart';

/// High-level business logic for the `model` table.
///
/// Uses raw SQL for multi-table operations (JOINs, pagination, transactions).
final class ModelRepository {
  const ModelRepository();

  Future<Database> get _db async => (await CivitaiDatabase.instance).db;

  // ---------------------------------------------------------------------------
  // Upsert with cascading lookups
  // ---------------------------------------------------------------------------

  /// Insert or update a model row and wire up its tags & creator.
  ///
  /// [modelJson] is the full CivitAI API JSON for the model (stored in the
  /// `json` column).  [creatorJson], [modelTypeName], [tagNames] are extracted
  /// from it by the caller.
  Future<void> upsertModel({
    required int id,
    required String name,
    required Map<String, dynamic>? creatorJson,
    required String modelTypeName,
    required List<String> tagNames,
    required bool nsfw,
    required int nsfwLevel,
    required Map<String, dynamic> modelJson,
  }) async {
    final db = await _db;

    await db.transaction((txn) async {
      // 1) Find-or-create creator
      int? creatorId;
      if (creatorJson != null && creatorJson['username'] != null) {
        final rows = await txn.rawQuery(
          'SELECT id FROM creator WHERE username = ?',
          [creatorJson['username']],
        );
        if (rows.isNotEmpty) {
          creatorId = rows.first['id'] as int;
          // Update link/image if provided
          await txn.rawUpdate(
            '''UPDATE creator SET link = COALESCE(?, link), image = COALESCE(?, image)
               WHERE id = ?''',
            [creatorJson['link'], creatorJson['image'], creatorId],
          );
        } else {
          creatorId = await txn.rawInsert(
            '''INSERT INTO creator (username, link, image) VALUES (?, ?, ?)''',
            [
              creatorJson['username'],
              creatorJson['link'],
              creatorJson['image'],
            ],
          );
        }
      }

      // 2) Find-or-create model type
      final typeRows = await txn.rawQuery(
        'SELECT id FROM model_type WHERE name = ?',
        [modelTypeName],
      );
      int typeId;
      if (typeRows.isNotEmpty) {
        typeId = typeRows.first['id'] as int;
      } else {
        typeId = await txn.rawInsert(
          'INSERT INTO model_type (name) VALUES (?)',
          [modelTypeName],
        );
      }

      // 3) Upsert model
      await txn.rawInsert(
        '''INSERT INTO model (id, name, creator_id, type_id, nsfw, nsfw_level, json, updated_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'))
           ON CONFLICT(id) DO UPDATE SET
             name=excluded.name,
             creator_id=excluded.creator_id,
             type_id=excluded.type_id,
             nsfw=excluded.nsfw,
             nsfw_level=excluded.nsfw_level,
             json=excluded.json,
             updated_at=datetime('now')''',
        [
          id,
          name,
          creatorId,
          typeId,
          nsfw ? 1 : 0,
          nsfwLevel,
          jsonEncode(modelJson),
        ],
      );

      // 4) Upsert tags and rebuild junction
      if (tagNames.isNotEmpty) {
        // Batch insert-or-ignore tags
        for (final tag in tagNames) {
          await txn.rawInsert('INSERT OR IGNORE INTO tag (name) VALUES (?)', [
            tag,
          ]);
        }
        // Re-link: delete old then insert new
        await txn.rawDelete('DELETE FROM model_tags WHERE model_id = ?', [id]);
        final tagRows = await txn.rawQuery(
          'SELECT id FROM tag WHERE name IN (${_placeholders(tagNames.length)})',
          tagNames,
        );
        for (final row in tagRows) {
          await txn.rawInsert(
            'INSERT OR IGNORE INTO model_tags (model_id, tag_id) VALUES (?, ?)',
            [id, row['id']],
          );
        }
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Paginated queries
  // ---------------------------------------------------------------------------

  /// Result of a paginated model query.
  ({List<Map<String, dynamic>> records, int totalCount}) _emptyPage() =>
      (records: <Map<String, dynamic>>[], totalCount: 0);

  /// Query models with optional filters and pagination.
  ///
  /// When [cursorId] is provided, uses cursor-based pagination (keyset).
  /// Otherwise uses offset-based pagination with [page] and [limit].
  Future<({List<Map<String, dynamic>> records, int totalCount})> queryModels({
    String? query,
    List<String>? tags,
    String? username,
    List<String>? types,
    bool? nsfw,
    List<String>? baseModels,
    int? cursorId,
    int? page,
    int limit = 20,
  }) async {
    final db = await _db;

    final where = _buildWhereClause(
      query: query,
      tags: tags,
      username: username,
      types: types,
      nsfw: nsfw,
      baseModels: baseModels,
    );

    final fromJoin = '''
      FROM model
      LEFT JOIN creator    ON creator.id    = model.creator_id
      LEFT JOIN model_type ON model_type.id = model.type_id''';

    final countSql =
        'SELECT COUNT(DISTINCT model.id) AS cnt $fromJoin ${where.clause}';
    final countResult = await db.rawQuery(countSql, where.args);
    final totalCount = (countResult.first['cnt'] as int?) ?? 0;
    if (totalCount == 0) return _emptyPage();

    final dataSql =
        '''
      SELECT DISTINCT model.*,
             creator.username AS creator_username,
             creator.link     AS creator_link,
             creator.image    AS creator_image,
             model_type.name  AS type_name
      $fromJoin
      ${where.clause}
      ORDER BY model.id DESC
      ${cursorId != null ? 'AND model.id < ?' : ''}
      LIMIT ?
      ${cursorId == null ? 'OFFSET ?' : ''}
    ''';

    final args = [...where.args];
    if (cursorId != null) {
      args.add(cursorId);
    }
    args.add(limit);
    if (cursorId == null) {
      final p = (page ?? 1).clamp(1, 999999);
      args.add((p - 1) * limit);
    }

    final records = await db.rawQuery(dataSql, args);
    return (records: records, totalCount: totalCount);
  }

  // ---------------------------------------------------------------------------
  // WHERE clause builder
  // ---------------------------------------------------------------------------

  ({String clause, List<Object?> args}) _buildWhereClause({
    String? query,
    List<String>? tags,
    String? username,
    List<String>? types,
    bool? nsfw,
    List<String>? baseModels,
  }) {
    final conditions = <String>[];
    final args = <Object?>[];

    if (query != null && query.isNotEmpty) {
      conditions.add('model.name LIKE ? COLLATE NOCASE');
      args.add('%$query%');
    }
    if (tags != null && tags.isNotEmpty) {
      conditions.add(
        '''model.id IN (SELECT mt.model_id FROM model_tags mt
           JOIN tag t ON t.id = mt.tag_id WHERE t.name IN (${_placeholders(tags.length)}))''',
      );
      args.addAll(tags);
    }
    if (username != null && username.isNotEmpty) {
      conditions.add('creator.username = ? COLLATE NOCASE');
      args.add(username);
    }
    if (types != null && types.isNotEmpty) {
      conditions.add('model_type.name IN (${_placeholders(types.length)})');
      args.addAll(types);
    }
    if (nsfw != null) {
      conditions.add('model.nsfw = ?');
      args.add(nsfw ? 1 : 0);
    }
    if (baseModels != null && baseModels.isNotEmpty) {
      conditions.add('''model.id IN (SELECT mv.model_id FROM model_version mv
           JOIN base_model bm ON bm.id = mv.base_model_id
           WHERE bm.name IN (${_placeholders(baseModels.length)}))''');
      args.addAll(baseModels);
    }

    final clause = conditions.isEmpty
        ? ''
        : 'WHERE ${conditions.join(' AND ')}';
    return (clause: clause, args: args);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Generate "?, ?, ?" placeholders.
  String _placeholders(int count) => List.filled(count, '?').join(', ');
}
