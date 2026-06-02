import 'package:flutter/material.dart';

import '../../../services/download/download_queue.dart';
import '../../../services/download/download_task.dart';

/// A single file's download progress within a batch.
class DownloadTaskTile extends StatelessWidget {
  final DownloadTask task;

  const DownloadTaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          _statusIcon(theme),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.fileName,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (task.status == DownloadTaskStatus.downloading) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: task.progress,
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(task.progress * 100).toStringAsFixed(0)}%  ·  ${task.sizeFormatted}',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ] else
                  Text(
                    task.sizeFormatted,
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          if (task.status == DownloadTaskStatus.failed &&
              task.errorMessage != null)
            Tooltip(
              message: task.errorMessage!,
              child: const Icon(
                Icons.info_outline,
                size: 14,
                color: Colors.red,
              ),
            ),
          if (task.status == DownloadTaskStatus.failed ||
              task.status == DownloadTaskStatus.cancelled)
            SizedBox(
              width: 24,
              height: 24,
              child: IconButton(
                icon: const Icon(Icons.refresh, size: 14),
                padding: EdgeInsets.zero,
                tooltip: 'Retry',
                onPressed: () => DownloadQueue.instance.retryTask(task.id),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusIcon(ThemeData theme) {
    switch (task.status) {
      case DownloadTaskStatus.completed:
        return const Icon(Icons.check_circle, size: 18, color: Colors.green);
      case DownloadTaskStatus.downloading:
        return SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: task.progress > 0 ? task.progress : null,
          ),
        );
      case DownloadTaskStatus.failed:
        return const Icon(Icons.error, size: 18, color: Colors.red);
      case DownloadTaskStatus.cancelled:
        return const Icon(Icons.cancel, size: 18, color: Colors.grey);
      case DownloadTaskStatus.pending:
        return Icon(
          Icons.hourglass_empty,
          size: 18,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        );
    }
  }
}
