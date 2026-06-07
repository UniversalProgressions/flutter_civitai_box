import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/download/download_queue.dart';
import '../../services/download/download_task.dart';
import 'download_fetch_tab.dart';
import 'download_magazine_tab.dart';
import 'widgets/download_batch_card.dart';

/// Download page with two tabs: Fetch (existing) and Magazine (new).
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

  @override
  Widget build(BuildContext context) {
    final hasQueue = _queueState.batches.isNotEmpty;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Download'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.search), text: 'Fetch'),
              Tab(icon: Icon(Icons.radio_button_unchecked), text: 'Magazine'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  DownloadFetchTab(queueState: _queueState),
                  const DownloadMagazineTab(),
                ],
              ),
            ),
            if (hasQueue) _buildQueueSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueSection() {
    final theme = Theme.of(context);
    final activeBatches = _queueState.activeBatches;
    final completedBatches = _queueState.completedBatchList;

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
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
    );
  }
}
