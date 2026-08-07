import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_civitai_box/civitai_api/civitai_api.dart';
import 'package:flutter_civitai_box/services/download/download_magazine_database.dart';
import 'package:flutter_civitai_box/services/download/download_magazine_item.dart';
import 'package:flutter_civitai_box/services/download/download_magazine_resolver.dart';
import 'package:flutter_civitai_box/settings/settings.dart';
import 'package:flutter_civitai_box/ui/download/widgets/magazine_item_tile.dart';

/// How the user adds rounds to the magazine: by a single model version ID, or
/// by browsing a model's versions and selecting one or more.
enum _LoadMode { versionId, modelId }

/// Magazine tab — staging area for model version downloads.
///
/// Users add model version IDs (Load), review the list, then trigger
/// sequential downloads (Fire). Rounds that fail 3 times cause a "jam"
/// requiring manual intervention (Skip or Retry).
///
/// For testing, pass [initialRounds] to pre-populate the list without
/// needing an async database read in [initState].
class DownloadMagazineTab extends StatefulWidget {
  final List<MagazineItem>? initialRounds;

  const DownloadMagazineTab({super.key, this.initialRounds});

  @override
  State<DownloadMagazineTab> createState() => _DownloadMagazineTabState();
}

class _DownloadMagazineTabState extends State<DownloadMagazineTab> {
  final _idCtrl = TextEditingController();
  final _magazineDb = const DownloadMagazineDatabase();

  List<MagazineItem> _rounds = [];
  bool _isFiring = false;
  bool _isLoading = false;
  String? _statusText;

  _LoadMode _mode = _LoadMode.versionId;

  // Model-ID browse state (see _onBrowseModel / _buildModelBrowseView).
  ModelById? _browsedModel;
  List<ModelByIdVersion> _browsedVersions = [];
  final Set<int> _selectedVersionIds = {};
  bool _browsingModel = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialRounds != null) {
      _rounds = widget.initialRounds!;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadRounds());
    }
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRounds() async {
    final rounds = await _magazineDb.loadAll();
    if (mounted) setState(() => _rounds = rounds);
  }

  bool get _canLoad {
    final text = _idCtrl.text.trim();
    final id = int.tryParse(text);
    return id != null && id > 0 && !_isLoading;
  }

  bool get _canFire {
    if (_isFiring) return false;
    if (_rounds.isEmpty) return false;
    // Can't fire if there's a failed (jammed) round
    if (_rounds.any((r) => r.status == MagazineItemStatus.failed)) return false;
    // Must have at least one pending round
    return _rounds.any((r) => r.status == MagazineItemStatus.pending);
  }

  bool get _hasRounds => _rounds.isNotEmpty;

  Future<void> _onLoad() async {
    if (_mode == _LoadMode.modelId) {
      await _onBrowseModel();
      return;
    }
    final id = int.tryParse(_idCtrl.text.trim());
    if (id == null) return;

    setState(() => _isLoading = true);
    try {
      final api = await _createApi();
      final result = await load(modelVersionId: id, api: api);

      if (!mounted) return;
      switch (result) {
        case LoadOk():
          _idCtrl.clear();
          await _loadRounds();
        case LoadError_(:final error):
          _showSnack(error.message);
      }
    } catch (e) {
      _showSnack('Load failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Fetch a model and its version details for browsing.
  Future<void> _onBrowseModel() async {
    final id = int.tryParse(_idCtrl.text.trim());
    if (id == null || id <= 0) return;

    setState(() => _isLoading = true);
    try {
      final api = await _createApi();
      final model = await api.models.getById(id);
      if (!mounted) return;
      setState(() {
        _browsedModel = model;
        _browsedVersions = model.modelVersions;
        _selectedVersionIds.clear();
        _browsingModel = true;
      });
    } on CivitaiApiException catch (e) {
      _showSnack(
        e.statusCode == 404
            ? 'Model not found. Check the ID or set an API key in Settings.'
            : 'API error (${e.statusCode}): ${e.message}',
      );
    } on CivitaiNetworkException catch (e) {
      _showSnack('Network error: ${e.message}');
    } catch (e) {
      _showSnack('Failed to load model: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Load every selected version from the browse view into the magazine.
  Future<void> _onLoadSelected() async {
    final ids = _selectedVersionIds.toList();
    if (ids.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final api = await _createApi();
      var added = 0;
      var skipped = 0;
      for (final id in ids) {
        final result = await load(modelVersionId: id, api: api);
        switch (result) {
          case LoadOk():
            added++;
          case LoadError_():
            skipped++;
        }
      }
      if (!mounted) return;
      _showSnack(
        'Added $added to magazine${skipped > 0 ? ', $skipped skipped' : ''}.',
      );
      setState(_resetBrowse);
      await _loadRounds();
    } catch (e) {
      _showSnack('Load failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetBrowse() {
    _browsedModel = null;
    _browsedVersions = [];
    _selectedVersionIds.clear();
    _browsingModel = false;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onFire() async {
    setState(() => _isFiring = true);
    StreamSubscription<FireEvent>? sub;

    try {
      final api = await _createApi();
      final events = fireProduction(magazineDb: _magazineDb, api: api);

      sub = events.listen((event) {
        if (!mounted) return;
        switch (event) {
          case FireRoundStarted():
          case FireRetrying():
          case FireRoundSkipped():
            _loadRounds();
          case FireRoundCompleted():
            _loadRounds();
          case FireJammed():
            _loadRounds();
          case FireDone(:final summary):
            _statusText =
                '✅ ${summary.completed} done'
                '${summary.failed > 0 ? ' · ❌ ${summary.failed} jammed' : ''}'
                '${summary.skipped > 0 ? ' · ⏭ ${summary.skipped} skipped' : ''}';
            setState(() {});
        }
      });

      await sub.asFuture();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fire error: $e')));
      }
    } finally {
      sub?.cancel();
      if (mounted) {
        setState(() => _isFiring = false);
        await _loadRounds();
      }
    }
  }

  Future<CivitaiApiClient> _createApi() async {
    final svc = await SettingsService.getInstance();
    return CivitaiApiClient(apiKey: svc.settings.civitaiApiToken);
  }

  Future<void> _onUnload(int magazineId) async {
    await _magazineDb.remove(magazineId);
    await _loadRounds();
  }

  Future<void> _onSkipFailed(int magazineId) async {
    await _magazineDb.skipFailedRound(magazineId);
    await _loadRounds();
  }

  Future<void> _onRetryFailed(int magazineId) async {
    await _magazineDb.retryFailedRound(magazineId);
    await _loadRounds();
  }

  Future<void> _onUnloadAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all rounds?'),
        content: const Text(
          'This will remove all non-firing rounds from the magazine.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _magazineDb.clear();
      await _loadRounds();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: SegmentedButton<_LoadMode>(
            segments: const [
              ButtonSegment(
                value: _LoadMode.versionId,
                label: Text('Version ID'),
                icon: Icon(Icons.layers, size: 16),
              ),
              ButtonSegment(
                value: _LoadMode.modelId,
                label: Text('Model ID'),
                icon: Icon(Icons.model_training, size: 16),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() {
              _mode = s.first;
              _resetBrowse();
            }),
          ),
        ),
        if (_browsingModel)
          Expanded(child: _buildModelBrowseView())
        else ...[
          _buildInputRow(),
          _buildHeaderRow(),
          if (_statusText != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                _statusText!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 4),
          Expanded(
            child: _rounds.isEmpty
                ? const Center(
                    child: Text(
                      'No rounds in magazine.\nEnter a version or model ID to add downloads.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: _rounds.length,
                    itemBuilder: (context, index) {
                      final round = _rounds[index];
                      return MagazineItemTile(
                        item: round,
                        onUnload: round.status != MagazineItemStatus.firing
                            ? () => _onUnload(round.id)
                            : null,
                        onSkip: round.status == MagazineItemStatus.failed
                            ? () => _onSkipFailed(round.id)
                            : null,
                        onRetry: round.status == MagazineItemStatus.failed
                            ? () => _onRetryFailed(round.id)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputRow() {
    final isModel = _mode == _LoadMode.modelId;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _idCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: isModel
                    ? 'Model ID (integer)'
                    : 'Model version ID (integer)',
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
              enabled: !_isLoading,
              onSubmitted: (_) {
                if (_canLoad) _onLoad();
              },
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _canLoad ? _onLoad : null,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isModel ? 'Browse' : 'Load'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(
            'Magazine (${_rounds.length})',
            style: theme.textTheme.titleSmall,
          ),
          const Spacer(),
          if (_hasRounds)
            TextButton(
              onPressed: _isFiring ? null : _onUnloadAll,
              child: const Text('Unload All'),
            ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _canFire ? _onFire : null,
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('Fire'),
          ),
        ],
      ),
    );
  }

  Widget _buildModelBrowseView() {
    final theme = Theme.of(context);
    final model = _browsedModel!;
    final selectedCount = _selectedVersionIds.length;

    return Column(
      children: [
        Container(
          color: theme.colorScheme.surfaceContainerLow,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: () => setState(_resetBrowse),
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
                      '${_browsedVersions.length} versions',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: selectedCount > 0 && !_isLoading
                    ? _onLoadSelected
                    : null,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_to_queue, size: 18),
                label: Text(
                  selectedCount > 0
                      ? 'Load ($selectedCount)'
                      : 'Select versions',
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _browsedVersions.isEmpty
              ? const Center(child: Text('No versions found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _browsedVersions.length,
                  itemBuilder: (_, i) =>
                      _buildVersionCard(_browsedVersions[i], theme),
                ),
        ),
      ],
    );
  }

  Widget _buildVersionCard(ModelByIdVersion vd, ThemeData theme) {
    final isSelected = _selectedVersionIds.contains(vd.id);
    final firstFile = vd.files.isNotEmpty ? vd.files.first : null;
    final sizeStr = firstFile != null ? _formatSize(firstFile.sizeKB) : '';
    final thumbnails = vd.images.take(4).map((i) => i.url).toList();

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
                  onChanged: _isLoading
                      ? null
                      : (v) => setState(() {
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
            if (thumbnails.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: thumbnails.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      thumbnails[i],
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox(width: 80),
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

  String _formatSize(double kb) {
    if (kb <= 0) return '';
    if (kb >= 1024 * 1024) {
      return '${(kb / (1024 * 1024)).toStringAsFixed(1)} GB';
    }
    if (kb >= 1024) return '${(kb / 1024).toStringAsFixed(0)} MB';
    return '${kb.toStringAsFixed(0)} KB';
  }
}
