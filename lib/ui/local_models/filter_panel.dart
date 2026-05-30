import 'package:flutter/material.dart';

/// Filter state passed back from the panel.
class ModelFilters {
  final String? query;
  final String? username;
  final List<String> types;
  final List<String> baseModels;
  final List<String> tags;
  final bool? nsfw;

  const ModelFilters({
    this.query,
    this.username,
    this.types = const [],
    this.baseModels = const [],
    this.tags = const [],
    this.nsfw,
  });

  bool get hasActiveFilters =>
      (query != null && query!.isNotEmpty) ||
      (username != null && username!.isNotEmpty) ||
      types.isNotEmpty ||
      baseModels.isNotEmpty ||
      tags.isNotEmpty ||
      nsfw != null;

  ModelFilters copyWith({
    String? query,
    String? username,
    List<String>? types,
    List<String>? baseModels,
    List<String>? tags,
    bool? nsfw,
    bool clearNsfw = false,
  }) {
    return ModelFilters(
      query: query ?? this.query,
      username: username ?? this.username,
      types: types ?? this.types,
      baseModels: baseModels ?? this.baseModels,
      tags: tags ?? this.tags,
      nsfw: clearNsfw ? null : (nsfw ?? this.nsfw),
    );
  }
}

/// Bottom sheet with search and filter controls.
class FilterPanel extends StatefulWidget {
  final ModelFilters initial;
  final ValueChanged<ModelFilters> onApply;

  const FilterPanel({super.key, required this.initial, required this.onApply});

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  late final TextEditingController _queryCtrl;
  late final TextEditingController _usernameCtrl;
  final List<String> _selectedTypes = [];
  final List<String> _selectedBaseModels = [];
  final List<String> _selectedTags = [];
  bool? _nsfw;

  static const _typeOptions = [
    'Checkpoint',
    'LORA',
    'VAE',
    'Controlnet',
    'Upscaler',
    'TextualInversion',
    'Hypernetwork',
    'AestheticGradient',
    'Poses',
    'LoCon',
    'DoRA',
    'MotionModule',
    'Wildcards',
    'Detection',
  ];
  static const _baseModelOptions = [
    'SD 1.5',
    'SDXL 1.0',
    'SDXL',
    'Pony',
    'Illustrious',
    'Flux.1',
    'SD 2.1',
    'SD 3',
    'Flux',
    'NoobAI',
  ];

  @override
  void initState() {
    super.initState();
    _queryCtrl = TextEditingController(text: widget.initial.query);
    _usernameCtrl = TextEditingController(text: widget.initial.username);
    _selectedTypes.addAll(widget.initial.types);
    _selectedBaseModels.addAll(widget.initial.baseModels);
    _selectedTags.addAll(widget.initial.tags);
    _nsfw = widget.initial.nsfw;
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    widget.onApply(
      ModelFilters(
        query: _queryCtrl.text.trim().isEmpty ? null : _queryCtrl.text.trim(),
        username: _usernameCtrl.text.trim().isEmpty
            ? null
            : _usernameCtrl.text.trim(),
        types: _selectedTypes,
        baseModels: _selectedBaseModels,
        tags: _selectedTags,
        nsfw: _nsfw,
      ),
    );
    Navigator.of(context).pop();
  }

  void _clear() {
    widget.onApply(const ModelFilters());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Filters', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _queryCtrl,
              decoration: const InputDecoration(
                labelText: 'Search name',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(
                labelText: 'Creator username',
                prefixIcon: Icon(Icons.person_outline),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            _chipSection('Type', _typeOptions, _selectedTypes),
            _chipSection('Base Model', _baseModelOptions, _selectedBaseModels),
            Row(
              children: [
                const Text('NSFW'),
                const Spacer(),
                ChoiceChip(
                  label: const Text('All'),
                  selected: _nsfw == null,
                  onSelected: (_) => setState(() => _nsfw = null),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Yes'),
                  selected: _nsfw == true,
                  onSelected: (_) => setState(() => _nsfw = true),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('No'),
                  selected: _nsfw == false,
                  onSelected: (_) => setState(() => _nsfw = false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(onPressed: _clear, child: const Text('Clear All')),
                const Spacer(),
                FilledButton(onPressed: _apply, child: const Text('Apply')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipSection(
    String label,
    List<String> options,
    List<String> selected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          children: options.map((o) {
            final active = selected.contains(o);
            return FilterChip(
              label: Text(o),
              selected: active,
              onSelected: (v) {
                setState(() {
                  if (v) {
                    selected.add(o);
                  } else {
                    selected.remove(o);
                  }
                });
              },
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
