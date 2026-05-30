import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../settings/settings.dart';

/// A Material 3 settings page with grouped cards and real-time validation.
///
/// Can be used as:
/// - A full-screen page pushed via `Navigator.push`
/// - A first-launch wizard (wrap in a `Scaffold` without back button)
class SettingsPage extends StatefulWidget {
  /// Called after settings are successfully saved.
  final VoidCallback? onSaved;

  /// When true, hides the back button (first-launch mode).
  final bool isFirstLaunch;

  const SettingsPage({super.key, this.onSaved, this.isFirstLaunch = false});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _basePathCtrl;
  late final TextEditingController _civitaiTokenCtrl;
  late final TextEditingController _gopeedHostCtrl;
  late final TextEditingController _gopeedTokenCtrl;
  late final TextEditingController _httpProxyCtrl;

  // Visibility toggles for token fields
  bool _civitaiTokenVisible = false;
  bool _gopeedTokenVisible = false;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _basePathCtrl = TextEditingController();
    _civitaiTokenCtrl = TextEditingController();
    _gopeedHostCtrl = TextEditingController();
    _gopeedTokenCtrl = TextEditingController();
    _httpProxyCtrl = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final svc = await SettingsService.getInstance();
    final s = svc.settingsOrNull;
    if (s == null) return;
    _basePathCtrl.text = s.basePath;
    _civitaiTokenCtrl.text = s.civitaiApiToken;
    _gopeedHostCtrl.text = s.gopeedApiHost;
    _gopeedTokenCtrl.text = s.gopeedApiToken ?? '';
    _httpProxyCtrl.text = s.httpProxy ?? '';
    setState(() => _error = null);
  }

  @override
  void dispose() {
    _basePathCtrl.dispose();
    _civitaiTokenCtrl.dispose();
    _gopeedHostCtrl.dispose();
    _gopeedTokenCtrl.dispose();
    _httpProxyCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final svc = await SettingsService.getInstance();
      svc.updateSettings({
        'basePath': _basePathCtrl.text.trim(),
        'civitai_api_token': _civitaiTokenCtrl.text.trim(),
        'gopeed_api_host': _gopeedHostCtrl.text.trim(),
        'gopeed_api_token': _gopeedTokenCtrl.text.trim().isEmpty
            ? null
            : _gopeedTokenCtrl.text.trim(),
        'http_proxy': _httpProxyCtrl.text.trim().isEmpty
            ? null
            : _httpProxyCtrl.text.trim(),
      });
      widget.onSaved?.call();
      if (mounted && !widget.isFirstLaunch) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Settings saved')));
        Navigator.of(context).maybePop();
      }
    } on SettingsUpdateError catch (e) {
      setState(() => _error = e.summary);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Directory picker
  // ---------------------------------------------------------------------------

  Future<void> _pickDirectory() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      _basePathCtrl.text = path;
      _formKey.currentState?.validate();
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: !widget.isFirstLaunch,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Error banner
            if (_error != null)
              Card(
                color: theme.colorScheme.errorContainer,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: theme.colorScheme.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Storage ──
            _buildSectionHeader('Storage'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Models Folder', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _basePathCtrl,
                            decoration: const InputDecoration(
                              hintText: '/path/to/models',
                              prefixIcon: Icon(Icons.folder_outlined),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonalIcon(
                          onPressed: _pickDirectory,
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Browse'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── API Authentication ──
            _buildSectionHeader('API Authentication'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CivitAI API Token',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _civitaiTokenCtrl,
                      obscureText: !_civitaiTokenVisible,
                      decoration: InputDecoration(
                        hintText: 'Paste your CivitAI API token',
                        prefixIcon: const Icon(Icons.vpn_key_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _civitaiTokenVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _civitaiTokenVisible = !_civitaiTokenVisible,
                          ),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Downloader ──
            _buildSectionHeader('Downloader'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gopeed Host', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _gopeedHostCtrl,
                      decoration: const InputDecoration(
                        hintText: 'http://localhost:8080',
                        prefixIcon: Icon(Icons.dns_outlined),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gopeed API Token (optional)',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _gopeedTokenCtrl,
                      obscureText: !_gopeedTokenVisible,
                      decoration: InputDecoration(
                        hintText: 'Only if Gopeed has auth enabled',
                        prefixIcon: const Icon(Icons.key_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _gopeedTokenVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _gopeedTokenVisible = !_gopeedTokenVisible,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Proxy ──
            _buildSectionHeader('Proxy (optional)'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _httpProxyCtrl,
                  decoration: const InputDecoration(
                    hintText: 'http://proxy:3128',
                    prefixIcon: Icon(Icons.router_outlined),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Save ──
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(widget.isFirstLaunch ? 'Get Started' : 'Save'),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
