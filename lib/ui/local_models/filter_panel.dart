import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../civitai_api/models/enums.dart';
import '../../db/database.dart';
import '../../db/dao/saved_search_dao.dart';
import '../../db/dao/tag_dao.dart';

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

  Map<String, dynamic> toJson() => {
    if (query != null) 'query': query,
    if (username != null) 'username': username,
    'types': types,
    'baseModels': baseModels,
    'tags': tags,
    if (nsfw != null) 'nsfw': nsfw,
  };

  static ModelFilters fromJson(Map<String, dynamic> json) => ModelFilters(
    query: json['query'] as String?,
    username: json['username'] as String?,
    types: List<String>.from(json['types'] ?? []),
    baseModels: List<String>.from(json['baseModels'] ?? []),
    tags: List<String>.from(json['tags'] ?? []),
    nsfw: json['nsfw'] as bool?,
  );
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
  late final TextEditingController _typeCtrl;
  late final TextEditingController _baseModelCtrl;
  final FocusNode _typeFocus = FocusNode();
  final FocusNode _baseModelFocus = FocusNode();
  final List<String> _typeSuggestions = [];
  final List<String> _baseModelSuggestions = [];
  late final TextEditingController _tagCtrl;
  final FocusNode _tagFocus = FocusNode();
  Timer? _tagDebounce;
  Timer? _usernameDebounce;
  final List<String> _tagSuggestions = [];
  final List<String> _usernameSuggestions = [];
  final List<String> _selectedTags = [];
  bool? _nsfw;

  // Saved search
  List<Map<String, Object?>> _savedSearches = [];
  String? _selectedPresetName;

  static final _typeOptions = ModelType.values.map((e) => e.value).toList();
  static final _baseModelOptions = BaseModel.values
      .map((e) => e.value)
      .toList();

  @override
  void initState() {
    super.initState();
    _queryCtrl = TextEditingController(text: widget.initial.query);
    _usernameCtrl = TextEditingController(text: widget.initial.username);
    _selectedTypes.addAll(widget.initial.types);
    _selectedBaseModels.addAll(widget.initial.baseModels);
    _typeCtrl = TextEditingController();
    _baseModelCtrl = TextEditingController();
    _tagCtrl = TextEditingController();
    _selectedTags.addAll(widget.initial.tags);
    _nsfw = widget.initial.nsfw;
    _loadSavedSearches();
    _typeFocus.addListener(() {
      if (_typeFocus.hasFocus) {
        _showAllOptions(_typeOptions, _selectedTypes, _typeSuggestions);
      }
    });
    _baseModelFocus.addListener(() {
      if (_baseModelFocus.hasFocus) {
        _showAllOptions(
          _baseModelOptions,
          _selectedBaseModels,
          _baseModelSuggestions,
        );
      }
    });
  }

  @override
  void dispose() {
    _tagDebounce?.cancel();
    _usernameDebounce?.cancel();
    _queryCtrl.dispose();
    _usernameCtrl.dispose();
    _typeCtrl.dispose();
    _baseModelCtrl.dispose();
    _typeFocus.dispose();
    _baseModelFocus.dispose();
    _tagCtrl.dispose();
    _tagFocus.dispose();
    super.dispose();
  }

  void _onTagFieldChanged(String value) {
    _tagDebounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() => _tagSuggestions.clear());
      return;
    }
    _tagDebounce = Timer(const Duration(milliseconds: 300), () async {
      final rows = await const TagDao().search(value.trim());
      if (!mounted) return;
      setState(() {
        _tagSuggestions.clear();
        for (final row in rows) {
          final name = row['name'] as String;
          if (!_selectedTags.contains(name)) {
            _tagSuggestions.add(name);
          }
        }
      });
    });
  }

  void _onUsernameFieldChanged(String value) {
    _usernameDebounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() => _usernameSuggestions.clear());
      return;
    }
    _usernameDebounce = Timer(const Duration(milliseconds: 300), () async {
      final db = (await CivitaiDatabase.instance).db;
      final rows = await db.rawQuery(
        'SELECT DISTINCT username FROM creator WHERE username LIKE ? COLLATE NOCASE LIMIT 20',
        ['%${value.trim()}%'],
      );
      if (!mounted) return;
      setState(() {
        _usernameSuggestions.clear();
        for (final row in rows) {
          _usernameSuggestions.add(row['username'] as String);
        }
      });
    });
  }

  void _addTag(String tag) {
    setState(() {
      _selectedTags.add(tag);
      _tagSuggestions.remove(tag);
    });
  }

  void _removeTag(String tag) {
    setState(() => _selectedTags.remove(tag));
  }

  // ---------------------------------------------------------------------------
  // Saved search
  // ---------------------------------------------------------------------------

  Future<void> _loadSavedSearches() async {
    const dao = SavedSearchDao();
    final rows = await dao.getAll();
    if (mounted) setState(() => _savedSearches = rows);
  }

  ModelFilters _currentFilters() => ModelFilters(
    query: _queryCtrl.text.trim().isEmpty ? null : _queryCtrl.text.trim(),
    username: _usernameCtrl.text.trim().isEmpty
        ? null
        : _usernameCtrl.text.trim(),
    types: _selectedTypes,
    baseModels: _selectedBaseModels,
    tags: _selectedTags,
    nsfw: _nsfw,
  );

  Future<void> _savePreset() async {
    final nameCtrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Search Preset'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. My LORAs',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;

    const dao = SavedSearchDao();
    await dao.upsert(name, jsonEncode(_currentFilters().toJson()));
    await _loadSavedSearches();
    setState(() => _selectedPresetName = name);
  }

  Future<void> _loadPreset(String name) async {
    const dao = SavedSearchDao();
    final row = await dao.getByName(name);
    if (row == null) return;
    final json = row['json'] as String;
    final filters = ModelFilters.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
    setState(() {
      _selectedPresetName = name;
      _queryCtrl.text = filters.query ?? '';
      _usernameCtrl.text = filters.username ?? '';
      _selectedTypes
        ..clear()
        ..addAll(filters.types);
      _selectedBaseModels
        ..clear()
        ..addAll(filters.baseModels);
      _selectedTags
        ..clear()
        ..addAll(filters.tags);
      _nsfw = filters.nsfw;
    });
  }

  Future<void> _deletePreset(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Preset'),
        content: Text('Delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    const dao = SavedSearchDao();
    await dao.deleteByName(name);
    await _loadSavedSearches();
    if (_selectedPresetName == name) {
      setState(() => _selectedPresetName = null);
    }
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
            if (_savedSearches.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue:
                          _savedSearches.any(
                            (s) => s['name'] == _selectedPresetName,
                          )
                          ? _selectedPresetName
                          : null,
                      hint: const Text('Saved presets…'),
                      isExpanded: true,
                      isDense: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      items: _savedSearches
                          .map(
                            (s) => DropdownMenuItem(
                              value: s['name'] as String,
                              child: Text(
                                s['name'] as String,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) _loadPreset(v);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.save_outlined),
                    tooltip: 'Save current filters',
                    visualDensity: VisualDensity.compact,
                    onPressed: _currentFilters().hasActiveFilters
                        ? _savePreset
                        : null,
                  ),
                  if (_selectedPresetName != null)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      tooltip: 'Delete "$_selectedPresetName"',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _deletePreset(_selectedPresetName!),
                    ),
                ],
              ),
            ],
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
            _usernameAutocompleteSection(),
            const SizedBox(height: 12),
            _searchableChipSection(
              label: 'Type',
              allOptions: _typeOptions,
              selected: _selectedTypes,
              suggestions: _typeSuggestions,
              controller: _typeCtrl,
              focusNode: _typeFocus,
              icon: Icons.category_outlined,
              onChanged: (v) => _onLocalFilterChanged(
                v,
                _typeOptions,
                _selectedTypes,
                _typeSuggestions,
              ),
              onAdd: (v) => setState(() => _selectedTypes.add(v)),
              onRemove: (v) => setState(() => _selectedTypes.remove(v)),
              onClearAll: () => setState(() => _selectedTypes.clear()),
              onDismiss: () => setState(() => _typeSuggestions.clear()),
            ),
            _searchableChipSection(
              label: 'Base Model',
              allOptions: _baseModelOptions,
              selected: _selectedBaseModels,
              suggestions: _baseModelSuggestions,
              controller: _baseModelCtrl,
              focusNode: _baseModelFocus,
              icon: Icons.architecture,
              onChanged: (v) => _onLocalFilterChanged(
                v,
                _baseModelOptions,
                _selectedBaseModels,
                _baseModelSuggestions,
              ),
              onAdd: (v) => setState(() => _selectedBaseModels.add(v)),
              onRemove: (v) => setState(() => _selectedBaseModels.remove(v)),
              onClearAll: () => setState(() => _selectedBaseModels.clear()),
              onDismiss: () => setState(() => _baseModelSuggestions.clear()),
            ),
            const SizedBox(height: 8),
            _tagAutocompleteSection(),
            const SizedBox(height: 8),
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

  // ---------------------------------------------------------------------------
  // Local-filter multi-select (Type / Base Model)
  // ---------------------------------------------------------------------------

  void _showAllOptions(
    List<String> allOptions,
    List<String> selected,
    List<String> suggestions,
  ) {
    setState(() {
      suggestions.clear();
      for (final opt in allOptions) {
        if (!selected.contains(opt)) suggestions.add(opt);
      }
    });
  }

  void _onLocalFilterChanged(
    String value,
    List<String> allOptions,
    List<String> selected,
    List<String> suggestions,
  ) {
    setState(() {
      suggestions.clear();
      if (value.trim().isEmpty) return;
      final lower = value.trim().toLowerCase();
      for (final opt in allOptions) {
        if (!selected.contains(opt) && opt.toLowerCase().contains(lower)) {
          suggestions.add(opt);
        }
      }
    });
  }

  Widget _searchableChipSection({
    required String label,
    required List<String> allOptions,
    required List<String> selected,
    required List<String> suggestions,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required ValueChanged<String> onChanged,
    required ValueChanged<String> onAdd,
    required ValueChanged<String> onRemove,
    required VoidCallback onClearAll,
    required VoidCallback onDismiss,
  }) {
    final showSuggestions = suggestions.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            if (selected.isNotEmpty)
              TextButton(
                onPressed: () {
                  onClearAll();
                  _showAllOptions(allOptions, selected, suggestions);
                },
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Clear all', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 4),
        if (selected.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Wrap(
              spacing: 6,
              children: selected
                  .map(
                    (t) => Chip(
                      label: Text(t),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        onRemove(t);
                        _onLocalFilterChanged(
                          controller.text,
                          allOptions,
                          selected,
                          suggestions,
                        );
                      },
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
            ),
          ),
        TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Search $label…',
            prefixIcon: Icon(icon),
            isDense: true,
            suffixIcon: showSuggestions
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onDismiss,
                    visualDensity: VisualDensity.compact,
                  )
                : null,
          ),
          onChanged: onChanged,
        ),
        if (showSuggestions)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: suggestions
                  .map(
                    (v) => ListTile(
                      dense: true,
                      title: Text(v),
                      onTap: () {
                        onAdd(v);
                        suggestions.remove(v);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Username autocomplete
  // ---------------------------------------------------------------------------

  Widget _usernameAutocompleteSection() {
    final showSuggestions =
        _usernameCtrl.text.isNotEmpty && _usernameSuggestions.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _usernameCtrl,
          decoration: InputDecoration(
            labelText: 'Creator username',
            prefixIcon: const Icon(Icons.person_outline),
            isDense: true,
            suffixIcon: _usernameCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _usernameCtrl.clear();
                      setState(() => _usernameSuggestions.clear());
                    },
                    visualDensity: VisualDensity.compact,
                  )
                : null,
          ),
          onChanged: _onUsernameFieldChanged,
        ),
        if (showSuggestions)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: _usernameSuggestions
                  .map(
                    (u) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.person, size: 18),
                      title: Text(u),
                      onTap: () {
                        _usernameCtrl.text = u;
                        _usernameCtrl.selection = TextSelection.collapsed(
                          offset: u.length,
                        );
                        setState(() => _usernameSuggestions.clear());
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tag autocomplete
  // ---------------------------------------------------------------------------

  Widget _tagAutocompleteSection() {
    final showSuggestions =
        _tagCtrl.text.isNotEmpty && _tagSuggestions.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + Clear all
        Row(
          children: [
            Text('Tags', style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            if (_selectedTags.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _selectedTags.clear()),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Clear all', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 4),
        if (_selectedTags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Wrap(
              spacing: 6,
              children: _selectedTags
                  .map(
                    (t) => Chip(
                      label: Text(t),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _removeTag(t),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
            ),
          ),
        TextField(
          controller: _tagCtrl,
          focusNode: _tagFocus,
          decoration: InputDecoration(
            labelText: 'Search tags…',
            prefixIcon: const Icon(Icons.label_outline),
            isDense: true,
            suffixIcon: showSuggestions
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _tagSuggestions.clear()),
                    visualDensity: VisualDensity.compact,
                  )
                : null,
          ),
          onChanged: _onTagFieldChanged,
        ),
        if (showSuggestions)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: _tagSuggestions
                  .map(
                    (t) => ListTile(
                      dense: true,
                      title: Text(t),
                      onTap: () => _addTag(t),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
