import 'package:flutter/material.dart';
import 'package:flutter_civitai_box/services/download/download_magazine_item.dart';

/// Format bytes to human-readable string.
String _formatSize(double kb) {
  if (kb <= 0) return '0 KB';
  if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
  final mb = kb / 1024;
  if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
  final gb = mb / 1024;
  return '${gb.toStringAsFixed(1)} GB';
}

/// A single round row in the magazine list.
///
/// Displays the model version info, status icon, and action buttons
/// depending on the round's [MagazineItemStatus].
class MagazineItemTile extends StatelessWidget {
  final MagazineItem item;
  final VoidCallback? onUnload;
  final VoidCallback? onSkip;
  final VoidCallback? onRetry;

  const MagazineItemTile({
    super.key,
    required this.item,
    this.onUnload,
    this.onSkip,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildStatusIcon(),
            const SizedBox(width: 12),
            Expanded(child: _buildInfo(theme)),
            if (_showUnloadButton) _buildUnloadButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (item.status) {
      case MagazineItemStatus.pending:
        return const Icon(Icons.radio_button_unchecked, size: 28);
      case MagazineItemStatus.firing:
        return const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case MagazineItemStatus.failed:
        return const Icon(Icons.error, size: 28, color: Colors.red);
      case MagazineItemStatus.skipped:
        return const Icon(Icons.skip_next, size: 28, color: Colors.orange);
    }
  }

  Widget _buildInfo(ThemeData theme) {
    final subtitle = _buildSubtitle(theme);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${item.modelName}${item.versionName != null ? ' — ${item.versionName}' : ''}',
          style: theme.textTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null) const SizedBox(height: 2),
        ?subtitle,
        if (item.status == MagazineItemStatus.failed &&
            item.errorMessage != null) ...[
          const SizedBox(height: 4),
          Text(
            item.errorMessage!,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          _buildUnjamButtons(),
        ],
      ],
    );
  }

  Widget? _buildSubtitle(ThemeData theme) {
    switch (item.status) {
      case MagazineItemStatus.pending:
      case MagazineItemStatus.firing:
        final parts = <String>[];
        if (item.modelType != null) parts.add(item.modelType!);
        parts.add('${item.fileCount} files');
        parts.add(_formatSize(item.totalSizeKb));
        return Text(parts.join(' · '), style: theme.textTheme.bodySmall);
      case MagazineItemStatus.failed:
        return Text(
          'Failed after ${item.retryCount} attempts',
          style: theme.textTheme.bodySmall,
        );
      case MagazineItemStatus.skipped:
        return Text('Skipped', style: theme.textTheme.bodySmall);
    }
  }

  Widget _buildUnjamButtons() {
    return Row(
      children: [
        TextButton.icon(
          onPressed: onSkip,
          icon: const Icon(Icons.skip_next, size: 16),
          label: const Text('Skip'),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Retry'),
        ),
      ],
    );
  }

  bool get _showUnloadButton =>
      item.status == MagazineItemStatus.pending ||
      item.status == MagazineItemStatus.skipped;

  Widget _buildUnloadButton() {
    return IconButton(
      icon: const Icon(Icons.close, size: 20),
      onPressed: onUnload,
      tooltip: 'Remove from magazine',
    );
  }
}
