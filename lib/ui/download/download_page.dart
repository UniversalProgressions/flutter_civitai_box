import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/download/download_queue.dart';
import '../../services/download/download_task.dart';
import 'download_magazine_tab.dart';
import 'widgets/download_batch_card.dart';

/// Download page — the Magazine (staging) tab plus the shared queue section.
///
/// The Fetch flow was removed (2026-08-08); the magazine is the single
/// download workflow. See docs/download/analysis.md.
class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  DownloadQueueState _queueState = const DownloadQueueState(
    tasks: [],
    totalBatches: 0,
    completedBatches: 0,
  );
  StreamSubscription<DownloadQueueState>? _queueSub;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _queueSub = DownloadQueue.instance.stateStream.listen((s) {
      if (mounted) setState(() => _queueState = s);
    });
    _queueState = DownloadQueue.instance.currentState;
  }

  @override
  void dispose() {
    _queueSub?.cancel();
    super.dispose();
  }

  void _onTogglePause() {
    if (_paused) {
      DownloadQueue.instance.resume();
    } else {
      DownloadQueue.instance.pause();
    }
    setState(() => _paused = !_paused);
  }

  @override
  Widget build(BuildContext context) {
    final hasQueue = _queueState.batches.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Download')),
      body: Column(
        children: [
          const Expanded(child: DownloadMagazineTab()),
          if (hasQueue) _buildQueueSection(),
        ],
      ),
    );
  }

  Widget _buildQueueSection() {
    final theme = Theme.of(context);
    final activeBatches = _queueState.activeBatches;
    final completedBatches = _queueState.completedBatchList;
    final hasCompleted = completedBatches.isNotEmpty;

    return Container(
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 4, 0),
            child: Row(
              children: [
                Text('Queue', style: theme.textTheme.titleSmall),
                const Spacer(),
                if (hasCompleted)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep, size: 18),
                    tooltip: 'Clear completed history',
                    onPressed: () => DownloadQueue.instance.clearHistory(),
                  ),
                IconButton(
                  icon: Icon(
                    _paused ? Icons.play_arrow : Icons.pause,
                    size: 18,
                  ),
                  tooltip: _paused ? 'Resume all' : 'Pause all',
                  onPressed: activeBatches.isEmpty ? null : _onTogglePause,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                if (activeBatches.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Active (${activeBatches.length})',
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                  ...activeBatches.map(
                    (e) => DownloadBatchCard(batchId: e.key, tasks: e.value),
                  ),
                ],
                if (completedBatches.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Text(
                      'Completed (${completedBatches.length})',
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                  ...completedBatches.map(
                    (e) => DownloadBatchCard(batchId: e.key, tasks: e.value),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
