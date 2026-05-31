import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:sanitize_html/sanitize_html.dart';

import '../../services/file_layout.dart';

/// Renders user-written Markdown notes (model-level + version-level)
/// as collapsible panels.  Shows nothing if neither note file exists.
class MarkdownNoteViewer extends StatefulWidget {
  final String basePath;
  final int modelId;
  final int modelVersionId;

  const MarkdownNoteViewer({
    super.key,
    required this.basePath,
    required this.modelId,
    required this.modelVersionId,
  });

  @override
  State<MarkdownNoteViewer> createState() => _MarkdownNoteViewerState();
}

class _MarkdownNoteViewerState extends State<MarkdownNoteViewer> {
  String? _modelHtml;
  String? _versionHtml;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  String? _readAndRender(String path) {
    final file = File(path);
    if (!file.existsSync()) return null;
    final raw = file.readAsStringSync();
    if (raw.trim().isEmpty) return null;
    final html = md.markdownToHtml(raw);
    return sanitizeHtml(html);
  }

  void _loadNotes() {
    _modelHtml = _readAndRender(
      getUserCustomModelNotePath(widget.basePath, widget.modelId),
    );
    _versionHtml = _readAndRender(
      getUserCustomVersionNotePath(
        widget.basePath,
        widget.modelId,
        widget.modelVersionId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_modelHtml == null && _versionHtml == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_modelHtml != null)
          _NotePanel(title: 'Model Note', html: _modelHtml!),
        if (_versionHtml != null)
          _NotePanel(title: 'Version Note', html: _versionHtml!),
      ],
    );
  }
}

class _NotePanel extends StatefulWidget {
  final String title;
  final String html;

  const _NotePanel({required this.title, required this.html});

  @override
  State<_NotePanel> createState() => _NotePanelState();
}

class _NotePanelState extends State<_NotePanel> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        initiallyExpanded: true,
        onExpansionChanged: (v) => setState(() => _expanded = v),
        trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: HtmlWidget(
              widget.html,
              textStyle: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
