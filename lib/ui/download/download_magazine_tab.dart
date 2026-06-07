import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_civitai_box/civitai_api/civitai_api.dart';
import 'package:flutter_civitai_box/services/download/download_magazine_database.dart';
import 'package:flutter_civitai_box/services/download/download_magazine_item.dart';
import 'package:flutter_civitai_box/services/download/download_magazine_resolver.dart';
import 'package:flutter_civitai_box/settings/settings.dart';
import 'package:flutter_civitai_box/ui/download/widgets/magazine_item_tile.dart';

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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Load failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        // Input row
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _idCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Model version ID (integer)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                  enabled: !_isLoading,
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
                    : const Text('Load'),
              ),
            ],
          ),
        ),

        // Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text(
                'Magazine (${_rounds.length})',
                style: Theme.of(context).textTheme.titleSmall,
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
        ),

        // Status bar (during/after Fire)
        if (_statusText != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              _statusText!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

        const SizedBox(height: 4),

        // Round list
        Expanded(
          child: _rounds.isEmpty
              ? const Center(
                  child: Text(
                    'No rounds in magazine.\nEnter a version ID and tap Load.',
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
    );
  }
}
