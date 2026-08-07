import 'package:flutter/material.dart';

import '../../../services/download/download_queue.dart';
import '../../../services/download/download_task.dart';
import '../../animation.dart';

/// A single file's download progress within a batch.
class DownloadTaskTile extends StatefulWidget {
  final DownloadTask task;

  const DownloadTaskTile({super.key, required this.task});

  @override
  State<DownloadTaskTile> createState() => _DownloadTaskTileState();
}

class _DownloadTaskTileState extends State<DownloadTaskTile> {
  double? _lastProgress;
  DateTime? _lastTime;
  double _speedKbPerSec = 0;

  DownloadTask get task => widget.task;

  /// Compute live download speed from progress deltas between builds.
  /// Only meaningful while the task is downloading and its size is known
  /// (media files have `fileSizeKb == 0`, so their speed shows nothing).
  void _updateSpeed() {
    final t = task;
    if (t.status == DownloadTaskStatus.downloading && t.fileSizeKb > 0) {
      final now = DateTime.now();
      final lastP = _lastProgress;
      final lastT = _lastTime;
      if (lastP != null && lastT != null) {
        final dProgress = t.progress - lastP;
        final dSec = now.difference(lastT).inMilliseconds / 1000.0;
        if (dSec > 0) {
          _speedKbPerSec = (dProgress * t.fileSizeKb) / dSec;
        }
      } else {
        _speedKbPerSec = 0;
      }
      _lastProgress = t.progress;
      _lastTime = now;
    } else {
      _speedKbPerSec = 0;
      _lastProgress = null;
      _lastTime = null;
    }
  }

  String _progressLabel() {
    final pct = '${(task.progress * 100).toStringAsFixed(0)}%';
    final size = task.sizeFormatted;
    if (_speedKbPerSec > 0) {
      return '$pct  ·  $size  ·  ${_formatSpeed(_speedKbPerSec)}';
    }
    return '$pct  ·  $size';
  }

  static String _formatSpeed(double kbPerSec) {
    if (kbPerSec >= 1024) {
      return '${(kbPerSec / 1024).toStringAsFixed(1)} MB/s';
    }
    return '${kbPerSec.toStringAsFixed(0)} KB/s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _updateSpeed();
    final isDownloading = task.status == DownloadTaskStatus.downloading;

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
                  style: TextStyle(
                    fontSize: 12,
                    // Highlight the file currently being downloaded.
                    fontWeight: isDownloading ? FontWeight.w600 : null,
                    color: isDownloading ? theme.colorScheme.primary : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (isDownloading) ...[
                  JellyProgressBar(value: task.progress, height: 4),
                  const SizedBox(height: 2),
                  Text(
                    _progressLabel(),
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
              child: Icon(
                Icons.info_outline,
                size: 14,
                color: theme.colorScheme.error,
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
        return const _JellyCompleteIcon();
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
        return Icon(Icons.error, size: 18, color: theme.colorScheme.error);
      case DownloadTaskStatus.cancelled:
        return Icon(
          Icons.cancel,
          size: 18,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        );
      case DownloadTaskStatus.pending:
        return Icon(
          Icons.hourglass_empty,
          size: 18,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Jelly-scale complete icon
// ---------------------------------------------------------------------------

/// Animates a checkmark icon with a springy pop-in:
/// scale 0 → ~1.3 → 1.0 over ~400ms via [jellyCurve].
class _JellyCompleteIcon extends StatelessWidget {
  const _JellyCompleteIcon();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduced = MediaQuery.of(context).disableAnimations;
    if (reduced) {
      return Icon(
        Icons.check_circle,
        size: 18,
        color: theme.colorScheme.tertiary,
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: jellyCurve,
      builder: (_, scale, _) {
        return Transform.scale(
          scale: scale,
          child: Icon(
            Icons.check_circle,
            size: 18,
            color: theme.colorScheme.tertiary,
          ),
        );
      },
    );
  }
}
