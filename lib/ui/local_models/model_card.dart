import 'dart:io';

import 'package:flutter/material.dart';
import '../animation.dart';
import 'media_thumbnail.dart';
import 'model_detail_page.dart';

/// A single model card in the grid.
class ModelCard extends StatelessWidget {
  final int modelId;
  final String name;
  final String typeName;
  final String? firstImagePath;

  /// Whether the card is in selection mode.
  final bool selectionMode;

  /// Whether this card is currently selected.
  final bool isSelected;

  /// Callback when the card is tapped in selection mode.
  final VoidCallback? onSelectionToggle;

  const ModelCard({
    super.key,
    required this.modelId,
    required this.name,
    required this.typeName,
    this.firstImagePath,
    this.selectionMode = false,
    this.isSelected = false,
    this.onSelectionToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? theme.colorScheme.primaryContainer.withAlpha(100)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: selectionMode ? onSelectionToggle : () => _showDetail(context),
        onLongPress: selectionMode ? null : onSelectionToggle,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thumbnail
                Expanded(
                  child: Hero(
                    tag: 'model_hero_$modelId',
                    child:
                        firstImagePath != null && File(firstImagePath!).existsSync()
                        ? MediaThumbnail(filePath: firstImagePath!)
                        : Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 32,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ),
                  ),
                ),
                // Label
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _TypeBadge(typeName),
                    ],
                  ),
                ),
              ],
            ),
            // Selection checkbox overlay
            if (selectionMode)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface.withAlpha(200),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isSelected ? Icons.check : Icons.radio_button_unchecked,
                    size: 24,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    Navigator.of(context).push(
      JellyPageRoute(
        builder: (_) => ModelDetailPage(
          modelId: modelId,
          modelName: name,
          typeName: typeName,
        ),
      ),
    );
  }
}

/// Small coloured badge for model type.
class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge(this.type);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _typeColor(type, theme.colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(type, style: TextStyle(fontSize: 11, color: color)),
    );
  }
}

Color _typeColor(String type, ColorScheme scheme) =>
    switch (type.toLowerCase()) {
      'checkpoint' => scheme.primary,
      'lora' => scheme.secondary,
      'vae' => scheme.tertiary,
      'controlnet' => scheme.error,
      'upscaler' => scheme.primaryContainer,
      'textualinversion' => scheme.secondaryContainer,
      _ => scheme.outline,
    };
