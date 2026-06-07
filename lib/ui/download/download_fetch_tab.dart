import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../civitai_api/civitai_api.dart';
import '../../db/db.dart';
import '../../services/download/download_queue.dart';
import '../../services/download/download_task.dart';
import '../../services/file_layout.dart';
import '../../services/logger.dart';
import '../../services/model_refresh_bus.dart';
import '../../settings/settings.dart';

/// Fetch tab — search for models/versions by ID and trigger downloads.
///
/// Extracted from the original [DownloadPage] to make room for the
/// Magazine tab alongside it.
class DownloadFetchTab extends StatefulWidget {
  final DownloadQueueState queueState;

  const DownloadFetchTab({super.key, required this.queueState});

  @override
  State<DownloadFetchTab> createState() => _DownloadFetchTabState();
}

enum _FetchMode { modelId, versionId }

class _DownloadFetchTabState extends State<DownloadFetchTab> {
  _FetchMode _mode = _FetchMode.modelId;
  final _idCtrl = TextEditingController();
  bool _loading = false;
  String? _status;
  bool _isError = false;
  String? _errorDetails;

  Model? _model;
  List<ModelVersionEndpointData> _versionDetails = [];
  final Set<int> _selectedVersionIds = {};

  @override
  void dispose() {
    _idCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Fetch
  // ---------------------------------------------------------------------------

  Future<CivitaiApiClient> _createApi() async {
    final svc = await SettingsService.getInstance();
    return CivitaiApiClient(
      apiKey: svc.settings.civitaiApiToken,
      baseUrl: 'https://civitai.com/api/v1',
    );
  }

  Future<void> _fetch() async {
    final text = _idCtrl.text.trim();
    final id = int.tryParse(text);
    if (id == null) {
      setState(() {
        _status = 'Please enter a valid numeric ID';
        _isError = true;
      });
      return;
    }

    setState(() {
      _loading = true;
      _status = 'Fetching…';
      _isError = false;
      _model = null;
      _versionDetails = [];
      _selectedVersionIds.clear();
    });

    try {
      final api = await _createApi();
      switch (_mode) {
        case _FetchMode.modelId:
          await _fetchByModelId(api, id);
        case _FetchMode.versionId:
          await _fetchByVersionId(api, id);
      }
    } on CivitaiApiException catch (e, st) {
      logger.error('API error fetching model', e, st);
      if (mounted) {
        setState(() {
          _status = e.statusCode == 404
              ? 'Not found. Check the ID or set an API key in Settings.'
              : 'API error (${e.statusCode}): ${e.message}';
          _errorDetails = null;
          _isError = true;
          _loading = false;
        });
      }
    } on CivitaiNetworkException catch (e, st) {
      logger.error('Network error fetching model', e, st);
      if (mounted) {
        setState(() {
          _status = 'Network error: ${e.message}';
          _errorDetails = null;
          _isError = true;
          _loading = false;
        });
      }
    } catch (e, st) {
      logger.error('Unexpected error during fetch', e, st);
      if (mounted) {
        setState(() {
          _status = _buildErrorSummary(e);
          _errorDetails = _buildErrorDetails(e, st);
          _isError = true;
          _loading = false;
        });
      }
    }
  }

  Future<void> _fetchByModelId(CivitaiApiClient api, int id) async {
    final model = await api.models.getModel(id);
    final details = <ModelVersionEndpointData>[];
    for (final mv in model.modelVersions) {
      try {
        final d = await api.modelVersions.getById(mv.id);
        details.add(d);
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _model = model;
        _versionDetails = details;
        _status = null;
        _loading = false;
      });
    }
  }

  Future<void> _fetchByVersionId(CivitaiApiClient api, int versionId) async {
    final vData = await api.modelVersions.getById(versionId);
    final model = await api.models.getModel(vData.modelId);
    if (mounted) {
      setState(() {
        _model = model;
        _versionDetails = [vData];
        _selectedVersionIds.add(versionId);
        _status = null;
        _loading = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Start Download (existing logic, unchanged)
  // ---------------------------------------------------------------------------

  Future<void> _startDownload() async {
    if (_model == null || _selectedVersionIds.isEmpty) return;
    final model = _model!;

    setState(() {
      _loading = true;
      _status = 'Preparing download…';
    });

    final svc = await SettingsService.getInstance();
    final basePath = svc.settingsOrNull?.basePath ?? '';
    final apiToken = svc.settingsOrNull?.civitaiApiToken ?? '';

    await _writeModelJson(basePath, model.type, model.id, model.toJson());
    await _upsertModel(model);
    for (final vd in _versionDetails) {
      if (!_selectedVersionIds.contains(vd.id)) continue;
      await _upsertVersion(vd, model);
    }

    for (final vd in _versionDetails) {
      if (!_selectedVersionIds.contains(vd.id)) continue;
      final batchId =
          '${model.id}-${vd.id}-${DateTime.now().millisecondsSinceEpoch}';

      await _writeVersionJson(
        basePath,
        model.type,
        model.id,
        vd.id,
        vd.toJson(),
      );

      final apiJsonTasks = [
        DownloadTask(
          id: '$batchId-json-model',
          batchId: batchId,
          modelId: model.id,
          modelVersionId: vd.id,
          fileName: '${model.id}.api-info.json',
          fileSizeKb: 0,
          downloadUrl: '',
          targetPath: getModelIdApiInfoJsonPath(basePath, model.type, model.id),
          fileType: DownloadFileType.apiJson,
          status: DownloadTaskStatus.completed,
          progress: 1.0,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
        DownloadTask(
          id: '$batchId-json-version',
          batchId: batchId,
          modelId: model.id,
          modelVersionId: vd.id,
          fileName: '${vd.id}.api-info.json',
          fileSizeKb: 0,
          downloadUrl: '',
          targetPath: getModelVersionApiInfoJsonPath(
            basePath,
            model.type,
            model.id,
            vd.id,
          ),
          fileType: DownloadFileType.apiJson,
          status: DownloadTaskStatus.completed,
          progress: 1.0,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ];

      final modelTasks = <DownloadTask>[];
      for (final f in vd.files.where((f) => f.type == 'Model')) {
        final resolvedUrl = await _resolveDownloadUrl(f.downloadUrl, apiToken);
        final filesDir = getFilesDir(basePath, model.type, model.id, vd.id);
        modelTasks.add(
          DownloadTask(
            id: '$batchId-f-${f.id}',
            batchId: batchId,
            modelId: model.id,
            modelVersionId: vd.id,
            fileName: f.name,
            fileSizeKb: f.sizeKB,
            downloadUrl: resolvedUrl,
            targetPath: '$filesDir/${f.name}',
            fileType: DownloadFileType.model,
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
        );
      }

      final mediaTasks = <DownloadTask>[];
      for (final img in vd.images.where(
        (img) => (img.type ?? 'image') == 'image',
      )) {
        final resolvedUrl = await _resolveDownloadUrl(img.url, apiToken);
        final imageId = extractIdFromImageUrl(img.url) ?? 0;
        final ext = _extensionFromUrl(img.url);
        final mediaDir = getMediaDir(basePath, model.type, model.id, vd.id);
        mediaTasks.add(
          DownloadTask(
            id: '$batchId-m-$imageId',
            batchId: batchId,
            modelId: model.id,
            modelVersionId: vd.id,
            fileName: '$imageId$ext',
            fileSizeKb: 0,
            downloadUrl: resolvedUrl,
            targetPath: '$mediaDir/$imageId$ext',
            fileType: DownloadFileType.media,
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
        );
      }

      await DownloadQueue.instance.enqueueBatch(
        batchId: batchId,
        apiJsonTasks: apiJsonTasks,
        modelTasks: modelTasks,
        mediaTasks: mediaTasks,
      );
    }

    ModelRefreshBus.instance.notify();

    if (mounted) {
      setState(() {
        _loading = false;
        _status = null;
        _model = null;
        _versionDetails = [];
        _selectedVersionIds.clear();
        _idCtrl.clear();
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _extensionFromUrl(String url) {
    final uri = Uri.tryParse(url);
    final path = uri?.path ?? url;
    final dotIdx = path.lastIndexOf('.');
    if (dotIdx == -1) return '.jpeg';
    final ext = path.substring(dotIdx);
    final qIdx = ext.indexOf('?');
    return qIdx == -1 ? ext : ext.substring(0, qIdx);
  }

  Future<String> _resolveDownloadUrl(String url, String apiToken) async {
    if (apiToken.isEmpty) return url;
    try {
      final api = CivitaiApiClient(apiKey: apiToken);
      return await api.modelVersions.resolveFileDownloadUrl(url);
    } catch (e) {
      logger.warning('Failed to resolve download URL, using raw URL: $e');
      return url;
    }
  }

  Future<void> _writeModelJson(
    String basePath,
    String modelType,
    int modelId,
    Map<String, dynamic> json,
  ) async {
    final filePath = getModelIdApiInfoJsonPath(basePath, modelType, modelId);
    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
  }

  Future<void> _writeVersionJson(
    String basePath,
    String modelType,
    int modelId,
    int versionId,
    Map<String, dynamic> json,
  ) async {
    final filePath = getModelVersionApiInfoJsonPath(
      basePath,
      modelType,
      modelId,
      versionId,
    );
    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
  }

  Future<void> _upsertModel(Model model) async {
    const repo = ModelRepository();
    await repo.upsertModel(
      id: model.id,
      name: model.name,
      creatorJson: model.creator != null
          ? {
              'username': model.creator!.username,
              'link': model.creator!.link,
              'image': model.creator!.image,
            }
          : null,
      modelTypeName: model.type,
      tagNames: model.tags,
      nsfw: model.nsfw,
      nsfwLevel: model.nsfwLevel,
      modelJson: model.toJson(),
    );
  }

  Future<void> _upsertVersion(
    ModelVersionEndpointData vData,
    Model model,
  ) async {
    const repo = ModelVersionRepository();
    final images = vData.images.map((img) {
      final imageId = extractIdFromImageUrl(img.url) ?? 0;
      return {
        'id': imageId,
        'url': img.url,
        'nsfwLevel': img.nsfwLevel,
        'width': img.width,
        'height': img.height,
        'hash': img.hash ?? '',
        'type': img.type,
      };
    }).toList();
    final files = vData.files
        .map(
          (f) => {
            'id': f.id,
            'sizeKB': f.sizeKB,
            'name': f.name,
            'type': f.type,
            'downloadUrl': f.downloadUrl,
          },
        )
        .toList();
    await repo.upsertVersion(
      id: vData.id,
      modelId: model.id,
      name: vData.name,
      baseModelName: vData.baseModel,
      baseModelTypeName: vData.baseModelType,
      nsfwLevel: vData.nsfwLevel,
      versionJson: vData.toJson(),
      modelJson: model.toJson(),
      modelName: model.name,
      creatorJson: model.creator != null
          ? {
              'username': model.creator!.username,
              'link': model.creator!.link,
              'image': model.creator!.image,
            }
          : null,
      modelTypeName: model.type,
      tagNames: model.tags,
      modelNsfw: model.nsfw,
      modelNsfwLevel: model.nsfwLevel,
      images: images,
      files: files,
    );
  }

  String _buildErrorSummary(Object e) => e is FormatException
      ? 'Invalid API response format'
      : 'Unexpected error occurred';

  String _buildErrorDetails(Object e, StackTrace st) {
    final buf = StringBuffer();
    buf.writeln('Error: $e');
    buf.writeln('StackTrace: $st');
    return buf.toString();
  }

  String _formatSize(double kb) {
    if (kb <= 0) return '';
    if (kb >= 1024 * 1024)
      return '${(kb / (1024 * 1024)).toStringAsFixed(1)} GB';
    if (kb >= 1024) return '${(kb / 1024).toStringAsFixed(0)} MB';
    return '${kb.toStringAsFixed(0)} KB';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_model != null) {
      return _buildModelView(theme);
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: _buildInputSection(theme),
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<_FetchMode>(
          segments: const [
            ButtonSegment(
              value: _FetchMode.modelId,
              label: Text('Model ID'),
              icon: Icon(Icons.model_training, size: 18),
            ),
            ButtonSegment(
              value: _FetchMode.versionId,
              label: Text('Version ID'),
              icon: Icon(Icons.layers, size: 18),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: (s) => setState(() => _mode = s.first),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _idCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: _mode == _FetchMode.modelId ? 'Model ID' : 'Version ID',
            hintText: _mode == _FetchMode.modelId
                ? 'e.g. 11821'
                : 'e.g. 1805971',
            prefixIcon: const Icon(Icons.tag),
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _fetch(),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _loading ? null : _fetch,
          icon: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cloud_download),
          label: Text(_loading ? 'Fetching…' : 'Fetch from CivitAI'),
        ),
        if (_status != null) ...[
          const SizedBox(height: 16),
          _buildStatusRow(theme),
        ],
      ],
    );
  }

  Widget _buildModelView(ThemeData theme) {
    final model = _model!;
    final selectedCount = _selectedVersionIds.length;

    return Column(
      children: [
        Container(
          color: theme.colorScheme.surfaceContainerLow,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _model = null;
                  _versionDetails = [];
                  _selectedVersionIds.clear();
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.name,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${_versionDetails.length} versions',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: selectedCount > 0 ? _startDownload : null,
                icon: const Icon(Icons.download, size: 18),
                label: Text(
                  selectedCount > 0
                      ? 'Download ($selectedCount)'
                      : 'Select versions',
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _versionDetails.length,
            itemBuilder: (_, i) => _buildVersionCard(_versionDetails[i], theme),
          ),
        ),
      ],
    );
  }

  Widget _buildVersionCard(ModelVersionEndpointData vd, ThemeData theme) {
    final isSelected = _selectedVersionIds.contains(vd.id);
    final firstFile = vd.files.isNotEmpty ? vd.files.first : null;
    final sizeStr = firstFile != null ? _formatSize(firstFile.sizeKB) : '';
    final thumbnailUrls = vd.images.take(4).map((i) => i.url).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _selectedVersionIds.add(vd.id);
                    } else {
                      _selectedVersionIds.remove(vd.id);
                    }
                  }),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vd.name,
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        vd.baseModel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                if (firstFile != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 140,
                        child: Text(
                          firstFile.name,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Text(
                        sizeStr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (thumbnailUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: thumbnailUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      thumbnailUrls[i],
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(width: 80),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _isError ? Icons.error_outline : Icons.info_outline,
              size: 16,
              color: _isError
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _status!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _isError
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        if (_errorDetails != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SelectableText(
              _errorDetails!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
