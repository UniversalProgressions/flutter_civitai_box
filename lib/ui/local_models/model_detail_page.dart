import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../civitai_api/utils.dart';
import '../../db/db.dart';
import '../../services/file_layout.dart';
import '../../settings/settings.dart';
import 'media_thumbnail.dart';

/// Full-screen model detail page.
class ModelDetailPage extends StatefulWidget {
  final int modelId;
  final String modelName;
  final String typeName;

  const ModelDetailPage({
    super.key,
    required this.modelId,
    required this.modelName,
    required this.typeName,
  });

  @override
  State<ModelDetailPage> createState() => _ModelDetailPageState();
}

class _ModelDetailPageState extends State<ModelDetailPage>
    with TickerProviderStateMixin {
  List<_VersionDetail> _versions = [];
  bool _loading = true;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await CivitaiDatabase.instance;
    final rows = await db.db.rawQuery(
      'SELECT mv.*, mt.name AS model_type_name '
      'FROM model_version mv '
      'JOIN model m ON m.id = mv.model_id '
      'JOIN model_type mt ON mt.id = m.type_id '
      'WHERE mv.model_id = ? ORDER BY mv.id DESC',
      [widget.modelId],
    );
    final settings = await SettingsService.getInstance();
    final basePath = settings.settingsOrNull?.basePath ?? '';
    final versions = <_VersionDetail>[];
    for (final v in rows) {
      final vid = v['id'] as int;
      final typeName = v['model_type_name'] as String;
      final rawImages = await db.db.rawQuery(
        'SELECT * FROM model_version_image WHERE model_version_id = ?',
        [vid],
      );
      final images = <_MediaItem>[];
      for (final img in rawImages) {
        final url = img['url'] as String;
        final imageId = extractIdFromImageUrl(url).fold((_) => 0, (id) => id);
        final mediaDir = getMediaDir(basePath, typeName, widget.modelId, vid);
        String? localPath;
        for (final ext in ['.jpeg', '.jpg', '.png', '.webp', '.gif', '.mp4']) {
          final p = '$mediaDir${Platform.pathSeparator}$imageId$ext';
          if (File(p).existsSync()) {
            localPath = p;
            break;
          }
        }
        images.add(_MediaItem(url: url, localPath: localPath));
      }
      final rawFiles = await db.db.rawQuery(
        'SELECT * FROM model_version_file WHERE model_version_id = ?',
        [vid],
      );
      final files = rawFiles
          .map(
            (f) => _FileItem(
              name: f['name'] as String? ?? '',
              sizeKb: (f['size_kb'] as num?)?.toDouble() ?? 0,
            ),
          )
          .toList();
      final jsonStr = v['json'] as String?;
      Map<String, dynamic>? jsonData;
      if (jsonStr != null && jsonStr.isNotEmpty) {
        try {
          jsonData =
              const JsonDecoder().convert(jsonStr) as Map<String, dynamic>;
        } catch (_) {}
      }
      final baseModel = await _resolveBaseModel(v, db);
      versions.add(
        _VersionDetail(
          name: v['name'] as String? ?? '',
          baseModel: baseModel,
          nsfwLevel: v['nsfw_level'] as int? ?? 0,
          createdAt: v['created_at'] as String?,
          description: _stripHtml(jsonData?['description'] as String?),
          images: images,
          files: files,
        ),
      );
    }

    if (mounted) {
      _tabController = TabController(length: versions.length, vsync: this);
      setState(() {
        _versions = versions;
        _loading = false;
      });
    }
  }

  Future<String> _resolveBaseModel(
    Map<String, dynamic> v,
    CivitaiDatabase db,
  ) async {
    final bmId = v['base_model_id'] as int?;
    if (bmId == null) return '';
    final rows = await db.db.rawQuery(
      'SELECT name FROM base_model WHERE id = ?',
      [bmId],
    );
    return rows.isNotEmpty ? (rows.first['name'] as String) : '';
  }

  String? _stripHtml(String? html) {
    if (html == null) return null;
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .trim();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.modelName)),
      body: _loading || _tabController == null
          ? const Center(child: CircularProgressIndicator())
          : _versions.isEmpty
          ? const Center(child: Text('No versions found'))
          : Column(
              children: [
                Container(
                  color: theme.colorScheme.surfaceContainerLow,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: _versions.map((v) => Tab(text: v.name)).toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _versions.map((v) => _VersionSection(v)).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}

// ────────────────────────────────────────────────────────
// Version section
// ────────────────────────────────────────────────────────

class _VersionSection extends StatefulWidget {
  final _VersionDetail version;
  const _VersionSection(this.version);

  @override
  State<_VersionSection> createState() => _VersionSectionState();
}

class _VersionSectionState extends State<_VersionSection> {
  int _currentImage = 0;
  final ScrollController _thumbnailScrollCtrl = ScrollController();

  @override
  void dispose() {
    _thumbnailScrollCtrl.dispose();
    super.dispose();
  }

  /// Scroll the thumbnail strip to bring the current image into view.
  void _scrollThumbnailIntoView() {
    if (!_thumbnailScrollCtrl.hasClients) return;
    // Each thumbnail: 60px wide + 2px left + 2px right margin = 64px
    const itemWidth = 64.0;
    final target = _currentImage * itemWidth;
    final viewport = _thumbnailScrollCtrl.position.viewportDimension;
    final maxScroll = _thumbnailScrollCtrl.position.maxScrollExtent;
    final offset = (target - viewport / 2 + itemWidth / 2).clamp(
      0.0,
      maxScroll,
    );
    _thumbnailScrollCtrl.animateTo(
      offset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.version;
    final theme = Theme.of(context);

    if (v.images.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: _buildInfoSection(v, theme),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    final size = MediaQuery.of(context).size;
    final landscape = size.width > size.height;

    if (landscape) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildGallery(theme, landscape: true)),
            const SizedBox(width: 24),
            Expanded(
              child: SingleChildScrollView(child: _buildInfoSection(v, theme)),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGallery(theme),
                      const SizedBox(height: 12),
                      _buildInfoSection(v, theme),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(_VersionDetail v, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(v.name, style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        _infoRow('Base Model', v.baseModel),
        _infoRow('NSFW Level', '${v.nsfwLevel}'),
        if (v.createdAt != null) _infoRow('Published', v.createdAt!),
        if (v.description != null && v.description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(v.description!, style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: 16),
        if (v.files.isNotEmpty) ...[
          Text('Files', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...v.files.map((f) => _FileRow(file: f)),
        ],
      ],
    );
  }

  Widget _buildGallery(ThemeData theme, {bool landscape = false}) {
    final images = widget.version.images;
    final current = images[_currentImage];

    Widget mainPreview = Stack(
      children: [
        GestureDetector(
          onTap: () => _openFullscreen(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: current.localPath != null
                ? MediaThumbnail(
                    key: ValueKey(current.localPath),
                    filePath: current.localPath!,
                    fit: BoxFit.contain,
                    autoPlay: true,
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 48),
                    ),
                  ),
          ),
        ),
        // Fullscreen button overlay (top-right)
        Positioned(
          top: 8,
          right: 8,
          child: IconButton.filledTonal(
            icon: const Icon(Icons.fullscreen, size: 20),
            onPressed: () => _openFullscreen(context),
          ),
        ),
      ],
    );

    return Column(
      children: [
        // Main preview — fills available height in landscape, fixed 300px in portrait
        if (landscape)
          Expanded(child: mainPreview)
        else
          SizedBox(height: 300, child: Center(child: mainPreview)),

        // Arrows + thumbnail strip
        if (images.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentImage > 0
                    ? () {
                        setState(() => _currentImage--);
                        _scrollThumbnailIntoView();
                      }
                    : null,
              ),
              Text('${_currentImage + 1} / ${images.length}'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentImage < images.length - 1
                    ? () {
                        setState(() => _currentImage++);
                        _scrollThumbnailIntoView();
                      }
                    : null,
              ),
            ],
          ),
          SizedBox(
            height: 64,
            child: Scrollbar(
              controller: _thumbnailScrollCtrl,
              child: ListView.builder(
                controller: _thumbnailScrollCtrl,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: images.length,
                itemBuilder: (_, i) {
                  final img = images[i];
                  final isActive = i == _currentImage;
                  final isVideo =
                      img.localPath != null &&
                      [
                        'mp4',
                        'mov',
                        'webm',
                      ].contains(img.localPath!.split('.').last.toLowerCase());
                  return GestureDetector(
                    onTap: () {
                      setState(() => _currentImage = i);
                      _scrollThumbnailIntoView();
                    },
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isActive
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: img.localPath != null
                            ? isVideo
                                  ? Container(
                                      color: Colors.grey[800],
                                      child: const Center(
                                        child: Icon(
                                          Icons.play_circle_fill,
                                          color: Colors.white70,
                                          size: 28,
                                        ),
                                      ),
                                    )
                                  : Image.file(
                                      File(img.localPath!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, e, s) =>
                                          Container(color: Colors.grey[300]),
                                    )
                            : Container(color: Colors.grey[300]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullscreenViewer(
          images: widget.version.images,
          initialIndex: _currentImage,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// File row with actions
// ────────────────────────────────────────────────────────

class _FileRow extends StatelessWidget {
  final _FileItem file;
  const _FileRow({required this.file});

  @override
  Widget build(BuildContext context) {
    final sizeStr = file.sizeKb > 1_000_000
        ? '${(file.sizeKb / 1_000_000).toStringAsFixed(1)} GB'
        : file.sizeKb > 1_000
        ? '${(file.sizeKb / 1_000).toStringAsFixed(1)} MB'
        : '${file.sizeKb.toStringAsFixed(0)} KB';
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.insert_drive_file_outlined),
        title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(sizeStr, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: 'Copy path',
              onPressed: () {
                // Note: _resolveFullPath needs the file path from disk layout
                Clipboard.setData(ClipboardData(text: file.name));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Path copied')));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// Fullscreen viewer
// ────────────────────────────────────────────────────────

class _FullscreenViewer extends StatelessWidget {
  final List<_MediaItem> images;
  final int initialIndex;

  const _FullscreenViewer({required this.images, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: images.length,
        itemBuilder: (_, i) {
          final img = images[i];
          return Center(
            child: img.localPath != null && File(img.localPath!).existsSync()
                ? InteractiveViewer(
                    child: MediaThumbnail(
                      filePath: img.localPath!,
                      fit: BoxFit.contain,
                      autoPlay: true,
                    ),
                  )
                : const Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 64,
                  ),
          );
        },
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// Data classes
// ────────────────────────────────────────────────────────

class _VersionDetail {
  final String name;
  final String baseModel;
  final int nsfwLevel;
  final String? createdAt;
  final String? description;
  final List<_MediaItem> images;
  final List<_FileItem> files;
  const _VersionDetail({
    required this.name,
    required this.baseModel,
    required this.nsfwLevel,
    this.createdAt,
    this.description,
    required this.images,
    required this.files,
  });
}

class _MediaItem {
  final String url;
  final String? localPath;
  const _MediaItem({required this.url, this.localPath});
}

class _FileItem {
  final String name;
  final double sizeKb;
  const _FileItem({required this.name, required this.sizeKb});
}
