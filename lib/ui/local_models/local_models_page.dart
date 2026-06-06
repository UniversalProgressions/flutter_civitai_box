import 'dart:io';

import 'package:flutter/material.dart';

import '../../civitai_api/utils.dart';
import '../../db/db.dart';
import '../../services/file_layout.dart';
import '../../services/model_refresh_bus.dart';
import '../../settings/nsfw_settings.dart';
import '../../settings/settings.dart';
import '../animation.dart';
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
  int _gridVersion = 0;
  ModelFilters _filters = const ModelFilters();
  static const _pageSize = 20;

  /// Parallel list: first image path for each model in [_models].
  final List<String?> _firstImages = [];

  /// Incremented at the start of each [_fetch]; stale generations are
  /// discarded to prevent length mismatches between [_models] and
  /// [_firstImages] when multiple fetches overlap.
  int _fetchGen = 0;

  final _jumpCtrl = TextEditingController();
  final _jumpFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetch();
    ModelRefreshBus.instance.addListener(_onDataChanged);
    NsfwSettings.instance!.addListener(_onNsfwChanged);
  }

  @override
  void dispose() {
    ModelRefreshBus.instance.removeListener(_onDataChanged);
    NsfwSettings.instance!.removeListener(_onNsfwChanged);
    _jumpCtrl.dispose();
    _jumpFocus.dispose();
    super.dispose();
  }

  void _onNsfwChanged() {
    _page = 1;
    _fetch();
  }

  void _onDataChanged() {
    _fetch();
  }

  Future<void> _fetch() async {
    final gen = ++_fetchGen;
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
    if (_filters.baseModels.isNotEmpty) {
      where.add(
        'EXISTS (SELECT 1 FROM model_version mv2 '
        'JOIN base_model bm ON bm.id = mv2.base_model_id '
        'WHERE mv2.model_id = m.id AND bm.name IN (${_filters.baseModels.map((_) => '?').join(',')}))',
      );
      args.addAll(_filters.baseModels);
    }
    if (_filters.tags.isNotEmpty) {
      where.add(
        'EXISTS (SELECT 1 FROM model_tags mtg '
        'JOIN tag t ON t.id = mtg.tag_id '
        'WHERE mtg.model_id = m.id AND t.name IN (${_filters.tags.map((_) => '?').join(',')}))',
      );
      args.addAll(_filters.tags);
    }

    // NSFW filter — from global app setting, not per-search filters
    final nsfwMode = NsfwSettings.instance!.mode;
    if (nsfwMode != NsfwFilter.all) {
      where.add('m.nsfw = ?');
      args.add(nsfwMode == NsfwFilter.yes ? 1 : 0);
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

    // Clamp page if data loss made current page invalid
    final tp = _totalCount == 0 ? 1 : _totalPages;
    if (_page > tp) _page = tp;

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
    final firstImages = <String?>[];
    for (final row in rows) {
      firstImages.add(await _findFirstImage(db, basePath, row));
    }

    // Discard if a newer fetch has started
    if (gen != _fetchGen) return;

    if (mounted) {
      setState(() {
        _models = rows;
        _firstImages
          ..clear()
          ..addAll(firstImages);
        _loading = false;
        _gridVersion++;
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
      body: _models.isEmpty && _loading
          ? const ShimmerGrid()
          : Column(
              children: [
                Expanded(
                  child: _models.isEmpty
                      ? Center(
                          child: JellyDriftIn(
                            show: true,
                            child: Text(
                              _filters.hasActiveFilters
                                  ? 'No models match your filters.'
                                  : 'No models found. Scan your models folder first.',
                            ),
                          ),
                        )
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: LayoutBuilder(
                            key: ValueKey(_gridVersion),
                            builder: (context, constraints) {
                              final cols = (constraints.maxWidth / 240).ceil();
                              final crossAxisCount = cols < 2
                                  ? 2
                                  : (cols > 6 ? 6 : cols);
                              return GridView.builder(
                                padding: const EdgeInsets.all(8),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      childAspectRatio: 0.75,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                itemCount: _models.length,
                                itemBuilder: (_, i) {
                                  final m = _models[i];
                                  // Guard: if _firstImages is out of sync
                                  // (stale fetch), show no image.
                                  final img = i < _firstImages.length
                                      ? _firstImages[i]
                                      : null;
                                  return _AnimatedModelCard(
                                    index: i,
                                    child: ModelCard(
                                      modelId: m['id'] as int,
                                      name: m['name'] as String,
                                      typeName:
                                          m['type_name'] as String? ?? 'Other',
                                      firstImagePath: img,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
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

// ---------------------------------------------------------------------------
// Animated model card — entrance, float, hover tilt
// ---------------------------------------------------------------------------

/// Wraps a [ModelCard] with staggered entrance, gentle floating, and
/// perspective tilt on hover. Uses [AutomaticKeepAliveClientMixin] so
/// animations survive scroll recycling.
class _AnimatedModelCard extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedModelCard({required this.index, required this.child});

  @override
  State<_AnimatedModelCard> createState() => _AnimatedModelCardState();
}

class _AnimatedModelCardState extends State<_AnimatedModelCard>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // ---------------------------------------------------------------------------
  // Keep-alive
  // ---------------------------------------------------------------------------

  @override
  bool get wantKeepAlive => true;

  // ---------------------------------------------------------------------------
  // Controllers
  // ---------------------------------------------------------------------------

  /// Drives the tilt spring-back when the mouse leaves.
  late final AnimationController _tiltReturnCtrl;

  // ---------------------------------------------------------------------------
  // Tilt
  // ---------------------------------------------------------------------------

  double _tiltRx = 0; // rotateY — horizontal mouse drives this
  double _tiltRy = 0; // rotateX — vertical mouse drives this
  double _startTiltRx = 0;
  double _startTiltRy = 0;
  bool _hovering = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    // Tilt spring-back
    _tiltReturnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _tiltReturnCtrl
      ..stop(canceled: true)
      ..dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Hover handlers
  // ---------------------------------------------------------------------------

  void _onHover(PointerEvent event) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final local = box.globalToLocal(event.position);
    final dx = (local.dx / box.size.width - 0.5) * 2; // -1 … +1
    final dy = (local.dy / box.size.height - 0.5) * 2;

    setState(() {
      _hovering = true;
      _tiltRx = dx * 0.10; // ±~6°
      _tiltRy = -dy * 0.10;
    });

    // Keep tilt-return controller at zero while hovering
    _tiltReturnCtrl.value = 0;
  }

  void _onExit(PointerEvent event) {
    _startTiltRx = _tiltRx;
    _startTiltRy = _tiltRy;
    setState(() => _hovering = false);
    _tiltReturnCtrl.forward(from: 0);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin requires this
    final reduced = MediaQuery.of(context).disableAnimations;
    if (reduced) return widget.child;

    return MouseRegion(
      onHover: _onHover,
      onExit: _onExit,
      child: AnimatedBuilder(
        animation: _tiltReturnCtrl,
        builder: (context, _) {
          // --- Compute tilt ---
          final tiltRx = _hovering
              ? _tiltRx
              : _startTiltRx * (1 - _tiltReturnCtrl.value);
          final tiltRy = _hovering
              ? _tiltRy
              : _startTiltRy * (1 - _tiltReturnCtrl.value);

          // --- Compute scale ---

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateX(tiltRy)
              ..rotateY(tiltRx),
            alignment: FractionalOffset.center,
            child: Transform.scale(
              scale: _hovering ? 1.04 : 1.0,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
