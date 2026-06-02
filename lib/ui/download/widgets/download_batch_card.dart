import 'package:flutter/material.dart';

import '../../../services/download/download_task.dart';
import 'download_task_tile.dart';

/// Card showing all files in one download batch (one ModelVersion).
class DownloadBatchCard extends StatefulWidget {
  final String batchId;
  final List<DownloadTask> tasks;

  const DownloadBatchCard({
    super.key,
    required this.batchId,
    required this.tasks,
  });

  @override
  State<DownloadBatchCard> createState() => _DownloadBatchCardState();
}

class _DownloadBatchCardState extends State<DownloadBatchCard> {
  bool _expanded = false;

  DownloadTaskStatus get _batchStatus {
    if (widget.tasks.every((t) => t.status == DownloadTaskStatus.completed)) {
      return DownloadTaskStatus.completed;
    }
    if (widget.tasks.any((t) => t.status == DownloadTaskStatus.downloading)) {
      return DownloadTaskStatus.downloading;
    }
    if (widget.tasks.any((t) => t.status == DownloadTaskStatus.failed)) {
      return DownloadTaskStatus.failed;
    }
    if (widget.tasks.every((t) => t.status == DownloadTaskStatus.cancelled)) {
      return DownloadTaskStatus.cancelled;
    }
    return DownloadTaskStatus.pending;
  }

  Color get _statusColor {
    switch (_batchStatus) {
      case DownloadTaskStatus.completed:
        return Colors.green;
      case DownloadTaskStatus.downloading:
        return Colors.blue;
      case DownloadTaskStatus.failed:
        return Colors.red;
      case DownloadTaskStatus.cancelled:
        return Colors.grey;
      case DownloadTaskStatus.pending:
        return Colors.orange;
    }
  }

  IconData get _statusIcon {
    switch (_batchStatus) {
      case DownloadTaskStatus.completed:
        return Icons.check_circle;
      case DownloadTaskStatus.downloading:
        return Icons.downloading;
      case DownloadTaskStatus.failed:
        return Icons.error;
      case DownloadTaskStatus.cancelled:
        return Icons.cancel;
      case DownloadTaskStatus.pending:
        return Icons.hourglass_empty;
    }
  }

  double get _overallProgress {
    if (widget.tasks.isEmpty) return 0;
    final total = widget.tasks.fold<double>(0, (s, t) => s + t.progress);
    return total / widget.tasks.length;
  }

  int get _totalFiles => widget.tasks.length;

  double get _totalSizeKb =>
      widget.tasks.fold<double>(0, (s, t) => s + t.fileSizeKb);

  String get _sizeFormatted {
    if (_totalSizeKb >= 1024 * 1024) {
      return '${(_totalSizeKb / (1024 * 1024)).toStringAsFixed(1)} GB';
    }
    if (_totalSizeKb >= 1024) {
      return '${(_totalSizeKb / 1024).toStringAsFixed(0)} MB';
    }
    return '${_totalSizeKb.toStringAsFixed(0)} KB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(_statusIcon, size: 20, color: _statusColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.tasks.first.modelId} / v${widget.tasks.first.modelVersionId}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (_batchStatus == DownloadTaskStatus.downloading)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: _overallProgress,
                              minHeight: 4,
                            ),
                          ),
                        Text(
                          '$_totalFiles files  ·  $_sizeFormatted',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Column(
                children: widget.tasks
                    .map((t) => DownloadTaskTile(task: t))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
