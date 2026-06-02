import 'dart:io';

import 'package:flutter/material.dart';

import '../../civitai_api/utils.dart';
import '../../db/db.dart';
import '../../services/file_layout.dart';
import '../../services/model_refresh_bus.dart';
import '../../settings/settings.dart';
import 'filter_panel.dart';
import 'model_card.dart';

/// Browse locally scanned models.
class LocalModelsPage extends StatefulWidget {
  const LocalModelsPage({super.key});

  @override
  State<LocalModelsPage> createState() => _LocalModelsPageState();
}

class _LocalModelsPageState extends State<LocalModelsPage> {
  List<Map<String, dynamic>> _models = [];
  int _totalCount = 0;
  int _page = 1;
  bool _loading = true;
  ModelFilters _filters = const ModelFilters();
  static const _pageSize = 20;

  /// Parallel list: first image path for each model in [_models].
  final List<String?> _firstImages = [];

  final _jumpCtrl = TextEditingController();
  final _jumpFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetch();
    ModelRefreshBus.instance.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    ModelRefreshBus.instance.removeListener(_onDataChanged);
    _jumpCtrl.dispose();
    _jumpFocus.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    _page = 1;
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final db = await CivitaiDatabase.instance;

    // Build WHERE clause from filters
    final where = <String>['1=1'];
    final args = <dynamic>[];
    if (_filters.query != null && _filters.query!.isNotEmpty) {
      where.add('m.name LIKE ?');
      args.add('%${_filters.query}%');
    }
    if (_filters.username != null && _filters.username!.isNotEmpty) {
      where.add(
        'EXISTS (SELECT 1 FROM creator c WHERE c.id = m.creator_id AND c.username = ?)',
      );
      args.add(_filters.username);
    }
    if (_filters.types.isNotEmpty) {
      where.add('mt.name IN (${_filters.types.map((_) => '?').join(',')})');
      args.addAll(_filters.types);
    }
    if (_filters.nsfw != null) {
      where.add('m.nsfw = ?');
      args.add(_filters.nsfw! ? 1 : 0);
    }

    final whereClause = where.join(' AND ');

    // Count
    final cnt = await db.db.rawQuery(
      'SELECT COUNT(DISTINCT m.id) AS cnt FROM model m '
      'JOIN model_type mt ON mt.id = m.type_id '
      'JOIN model_version mv ON mv.model_id = m.id '
      'WHERE $whereClause',
      args,
    );
    _totalCount = (cnt.first['cnt'] as int?) ?? 0;

    // Fetch page
    final rows = await db.db.rawQuery(
      'SELECT DISTINCT m.id, m.name, mt.name AS type_name '
      'FROM model m '
      'JOIN model_type mt ON mt.id = m.type_id '
      'JOIN model_version mv ON mv.model_id = m.id '
      'WHERE $whereClause '
      'ORDER BY m.id DESC LIMIT ? OFFSET ?',
      [...args, _pageSize, (_page - 1) * _pageSize],
    );

    // Attach first image path for each model
    final settings = await SettingsService.getInstance();
    final basePath = settings.settingsOrNull?.basePath ?? '';
    _firstImages.clear();
    for (final row in rows) {
      _firstImages.add(await _findFirstImage(db, basePath, row));
    }

    if (mounted) {
      setState(() {
        _models = rows;
        _loading = false;
      });
    }
  }

  Future<String?> _findFirstImage(
    CivitaiDatabase db,
    String basePath,
    Map<String, dynamic> modelRow,
  ) async {
    final modelId = modelRow['id'] as int;
    final imgRows = await db.db.rawQuery(
      'SELECT mvi.url, mvi.model_version_id, mv.model_id, m.type_id, mt.name AS type_name '
      'FROM model_version_image mvi '
      'JOIN model_version mv ON mv.id = mvi.model_version_id '
      'JOIN model m ON m.id = mv.model_id '
      'JOIN model_type mt ON mt.id = m.type_id '
      'WHERE m.id = ?',
      [modelId],
    );
    if (imgRows.isEmpty) return null;

    // Try each image until we find a non-video file on disk.
    const exts = [
      '.jpeg',
      '.jpg',
      '.png',
      '.webp',
      '.gif',
      '.mp4',
      '.mov',
      '.webm',
    ];
    const videoExts = {'.mp4', '.mov', '.webm'};

    for (final img in imgRows) {
      final versionId = img['model_version_id'] as int;
      final typeName = img['type_name'] as String;
      final url = img['url'] as String;

      final imageId = extractIdFromImageUrl(url);
      if (imageId == null) continue;

      final mediaDir = getMediaDir(basePath, typeName, modelId, versionId);
      for (final ext in exts) {
        final path = '$mediaDir${Platform.pathSeparator}$imageId$ext';
        if (File(path).existsSync()) {
          if (!videoExts.contains(ext)) return path; // image found
          break; // video — try next DB row
        }
      }
    }
    return null; // no non-video image found
  }

  int get _totalPages =>
      (_totalCount ~/ _pageSize) + (_totalCount % _pageSize == 0 ? 0 : 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local Models')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _models.isEmpty
          ? const Center(
              child: Text('No models found. Scan your models folder first.'),
            )
          : Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = (constraints.maxWidth / 240).ceil();
                      final crossAxisCount = cols < 2
                          ? 2
                          : (cols > 6 ? 6 : cols);
                      return GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _models.length,
                        itemBuilder: (_, i) {
                          final m = _models[i];
                          return ModelCard(
                            modelId: m['id'] as int,
                            name: m['name'] as String,
                            typeName: m['type_name'] as String? ?? 'Other',
                            firstImagePath: _firstImages[i],
                          );
                        },
                      );
                    },
                  ),
                ),
                _buildPagination(),
              ],
            ),
    );
  }

  void _jumpToPage() {
    final text = _jumpCtrl.text.trim();
    if (text.isEmpty) return;
    final n = int.tryParse(text);
    if (n == null || n < 1 || n > _totalPages) return;
    _jumpFocus.unfocus();
    _page = n;
    _fetch();
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilterChip(
              selected: _filters.hasActiveFilters,
              onSelected: (_) => _showFilters(),
              avatar: const Icon(Icons.search, size: 18),
              label: const Text('Query'),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _page > 1
                  ? () {
                      _page--;
                      _fetch();
                    }
                  : null,
            ),
            Text('$_page / $_totalPages'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _page < _totalPages
                  ? () {
                      _page++;
                      _fetch();
                    }
                  : null,
            ),
            const SizedBox(width: 8),
            const Text('Go to'),
            SizedBox(
              width: 56,
              child: TextField(
                controller: _jumpCtrl,
                focusNode: _jumpFocus,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  border: OutlineInputBorder(),
                  hintText: '#',
                ),
                onSubmitted: (_) => _jumpToPage(),
              ),
            ),
            TextButton(onPressed: _jumpToPage, child: const Text('Go')),
          ],
        ),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FilterPanel(
        initial: _filters,
        onApply: (f) {
          setState(() {
            _filters = f;
            _page = 1;
          });
          _fetch();
        },
      ),
    );
  }
}
