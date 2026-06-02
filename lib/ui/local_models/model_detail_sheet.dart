import 'dart:io';

import 'package:flutter/material.dart';

import '../../civitai_api/utils.dart';
import '../../db/db.dart';
import '../../services/file_layout.dart';
import '../../settings/settings.dart';
import 'media_thumbnail.dart';

/// Bottom sheet showing model versions with image gallery and file list.
class ModelDetailSheet extends StatefulWidget {
  final int modelId;
  final String modelName;
  final String typeName;

  const ModelDetailSheet({
    super.key,
    required this.modelId,
    required this.modelName,
    required this.typeName,
  });

  @override
  State<ModelDetailSheet> createState() => _ModelDetailSheetState();
}

class _ModelDetailSheetState extends State<ModelDetailSheet>
    with TickerProviderStateMixin {
  TabController? _tabController;
  List<_VersionData> _versions = [];
  bool _loading = true;

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
    final versions = <_VersionData>[];
    for (final v in rows) {
      final vid = v['id'] as int;
      final typeName = v['model_type_name'] as String;
      final rawImages = await db.db.rawQuery(
        'SELECT * FROM model_version_image WHERE model_version_id = ?',
        [vid],
      );
      final images = <_ImageData>[];
      for (final img in rawImages) {
        final url = img['url'] as String;
        final imageId = extractIdFromImageUrl(url) ?? 0;
        final mediaDir = getMediaDir(basePath, typeName, widget.modelId, vid);
        String? localPath;
        for (final ext in ['.jpeg', '.jpg', '.png', '.webp', '.gif', '.mp4']) {
          final p = '$mediaDir${Platform.pathSeparator}$imageId$ext';
          if (File(p).existsSync()) {
            localPath = p;
            break;
          }
        }
        images.add(
          _ImageData(
            url: url,
            localPath: localPath,
            width: img['width'] as int?,
            height: img['height'] as int?,
          ),
        );
      }
      final rawFiles = await db.db.rawQuery(
        'SELECT * FROM model_version_file WHERE model_version_id = ?',
        [vid],
      );
      final files = rawFiles
          .map(
            (f) => _FileData(
              name: f['name'] as String? ?? '',
              sizeKb: (f['size_kb'] as num?)?.toDouble() ?? 0,
            ),
          )
          .toList();
      versions.add(
        _VersionData(
          name: v['name'] as String? ?? '',
          images: images,
          files: files,
        ),
      );
    }

    if (mounted) {
      _tabController?.dispose();
      _tabController = TabController(length: versions.length, vsync: this);
      setState(() {
        _versions = versions;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        if (_loading || _tabController == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_versions.isEmpty) {
          return const Center(child: Text('No versions found'));
        }
        final hasTabs = _versions.length > 1;
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    widget.modelName,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_versions.length} version(s)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            if (hasTabs)
              TabBar(
                controller: _tabController!,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: _versions.map((v) => Tab(text: v.name)).toList(),
              ),
            Expanded(
              child: hasTabs
                  ? TabBarView(
                      controller: _tabController!,
                      children: _versions
                          .map((v) => _versionTab(v, scrollController))
                          .toList(),
                    )
                  : _versionTab(_versions.first, scrollController),
            ),
          ],
        );
      },
    );
  }

  Widget _versionTab(_VersionData version, ScrollController sc) {
    return ListView(
      controller: sc,
      padding: const EdgeInsets.all(16),
      children: [
        if (version.images.isNotEmpty) ...[
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: version.images.length,
              separatorBuilder: (_, s) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _imageTile(version.images[i]),
            ),
          ),
          const SizedBox(height: 16),
        ] else
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'No preview images',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        Text('Files', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        ...version.files.map(_fileRow),
        if (version.files.isEmpty)
          Text(
            'No files recorded',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  Widget _imageTile(_ImageData image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 180,
        child: image.localPath != null && File(image.localPath!).existsSync()
            ? MediaThumbnail(filePath: image.localPath!, fit: BoxFit.cover)
            : Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
      ),
    );
  }

  Widget _fileRow(_FileData file) {
    final sizeStr = file.sizeKb > 1_000_000
        ? '${(file.sizeKb / 1_000_000).toStringAsFixed(1)} GB'
        : file.sizeKb > 1_000
        ? '${(file.sizeKb / 1_000).toStringAsFixed(1)} MB'
        : '${file.sizeKb.toStringAsFixed(0)} KB';
    return ListTile(
      dense: true,
      leading: const Icon(Icons.insert_drive_file_outlined),
      title: Text(file.name),
      trailing: Text(sizeStr, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _VersionData {
  final String name;
  final List<_ImageData> images;
  final List<_FileData> files;
  const _VersionData({
    required this.name,
    required this.images,
    required this.files,
  });
}

class _ImageData {
  final String url;
  final String? localPath;
  final int? width;
  final int? height;
  const _ImageData({
    required this.url,
    this.localPath,
    this.width,
    this.height,
  });
}

class _FileData {
  final String name;
  final double sizeKb;
  const _FileData({required this.name, required this.sizeKb});
}
