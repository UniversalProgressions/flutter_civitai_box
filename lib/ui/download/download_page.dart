import 'package:flutter/material.dart';

import '../../civitai_api/civitai_api.dart';
import '../../db/db.dart';
import '../../services/model_refresh_bus.dart';
import '../../settings/settings.dart';
import '../local_models/model_detail_page.dart';

/// Page for downloading CivitAI models by ID.
///
/// Flow:
///   Fetch → show version cards → select → download or open detail page
class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

enum _FetchMode { modelId, versionId }

class _DownloadPageState extends State<DownloadPage> {
  _FetchMode _mode = _FetchMode.modelId;
  final _idCtrl = TextEditingController();
  bool _loading = false;
  String? _status;
  bool _isError = false;

  // Fetched data
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
    } on CivitaiApiException catch (e) {
      if (mounted) {
        setState(() {
          if (e.statusCode == 404) {
            _status =
                'Not found. Check the ID or set an API key in Settings for NSFW/private models.';
          } else {
            _status = 'API error (${e.statusCode})';
          }
          _isError = true;
          _loading = false;
        });
      }
    } on CivitaiNetworkException catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Network error: ${e.message}';
          _isError = true;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Unexpected error: $e';
          _isError = true;
          _loading = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Model ID → fetch all versions
  // ---------------------------------------------------------------------------

  Future<void> _fetchByModelId(CivitaiApiClient api, int id) async {
    final model = await api.models.getModel(id);
    final details = <ModelVersionEndpointData>[];
    for (final mv in model.modelVersions) {
      try {
        final d = await api.modelVersions.getById(mv.id);
        details.add(d);
      } catch (_) {
        // Skip versions that fail to load
      }
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

  // ---------------------------------------------------------------------------
  // Version ID → fetch parent model + target version
  // ---------------------------------------------------------------------------

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
  // Upsert & Navigate
  // ---------------------------------------------------------------------------

  Future<void> _upsertAndNavigate() async {
    if (_model == null) return;
    final model = _model!;

    setState(() {
      _loading = true;
      _status = 'Saving to database…';
    });

    await _upsertModel(model);
    for (final vd in _versionDetails) {
      await _upsertVersion(vd, model);
    }
    ModelRefreshBus.instance.notify();

    if (mounted) {
      setState(() {
        _loading = false;
        _status = null;
      });
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ModelDetailPage(
            modelId: model.id,
            modelName: model.name,
            typeName: model.type,
          ),
        ),
      );
      if (mounted) {
        setState(() {
          _model = null;
          _versionDetails = [];
          _selectedVersionIds.clear();
          _idCtrl.clear();
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // DB helpers
  // ---------------------------------------------------------------------------

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
        'hash': img.hash,
        'type': img.type,
      };
    }).toList();

    final files = vData.files.map((f) {
      return {
        'id': f.id,
        'sizeKB': f.sizeKB,
        'name': f.name,
        'type': f.type,
        'downloadUrl': f.downloadUrl,
      };
    }).toList();

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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_model != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Download')),
        body: _buildModelView(theme),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Download')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: _buildInputSection(theme),
          ),
        ),
      ),
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
        // Top bar
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
              FilledButton.tonalIcon(
                onPressed: _upsertAndNavigate,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(
                  selectedCount > 0
                      ? 'Detail ($selectedCount selected)'
                      : 'Detail Page',
                ),
              ),
            ],
          ),
        ),
        // Version cards
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
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selectedVersionIds.add(vd.id);
                      } else {
                        _selectedVersionIds.remove(vd.id);
                      }
                    });
                  },
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
                child: Row(
                  children: thumbnailUrls.map((url) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          url,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(ThemeData theme) {
    return Row(
      children: [
        if (_loading)
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          Icon(
            _isError ? Icons.error : Icons.check_circle,
            size: 16,
            color: _isError ? theme.colorScheme.error : Colors.green,
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _status!,
            style: TextStyle(color: _isError ? theme.colorScheme.error : null),
          ),
        ),
      ],
    );
  }

  String _formatSize(double sizeKB) {
    if (sizeKB > 1_000_000) {
      return '${(sizeKB / 1_000_000).toStringAsFixed(1)} GB';
    } else if (sizeKB > 1_000) {
      return '${(sizeKB / 1_000).toStringAsFixed(1)} MB';
    }
    return '${sizeKB.toStringAsFixed(0)} KB';
  }
}
