import 'package:flutter/material.dart';

import '../../db/db.dart';
import '../../services/model_refresh_bus.dart';
import '../../services/scanner/scan_result.dart';
import '../../services/scanner/scanner_service.dart';

/// Standalone scan page with progress UI.
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _scanning = false;
  ScanProgress? _scanProgress;
  ScanResult? _scanResult;
  String? _dbPath;

  @override
  void initState() {
    super.initState();
    _loadDbPath();
  }

  Future<void> _loadDbPath() async {
    final db = await CivitaiDatabase.instance;
    if (mounted) setState(() => _dbPath = db.path);
  }

  Future<void> _startScan() async {
    setState(() {
      _scanning = true;
      _scanProgress = null;
      _scanResult = null;
    });

    const scanner = ScannerService();
    final stream = scanner.scan();

    await for (final event in stream) {
      if (!mounted) return;
      setState(() {
        switch (event) {
          case ScanProgress():
            _scanProgress = event;
          case ScanResult():
            _scanResult = event;
            _scanning = false;
            ModelRefreshBus.instance.notify();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Models')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_scanning && _scanProgress != null) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Scanning: ${_scanProgress!.filesProcessed} / ${_scanProgress!.filesFound}',
                ),
                if (_scanProgress!.currentFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _scanProgress!.currentFile!,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (_scanProgress!.errors > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_scanProgress!.errors} errors so far',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ] else ...[
                FilledButton.icon(
                  onPressed: _startScan,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Scan Models'),
                ),
                if (_scanResult != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: _scanResult!.errors > 0
                            ? Theme.of(context).colorScheme.error
                            : Colors.green,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_scanResult!.upserted} upserted, '
                        '${_scanResult!.errors} errors '
                        '(${_scanResult!.duration.inSeconds}s)',
                      ),
                    ],
                  ),
                  if (_scanResult!.errors > 0)
                    SizedBox(
                      height: 80,
                      child: ListView(
                        children: _scanResult!.errorDetails
                            .take(3)
                            .map(
                              (e) => Text(
                                e,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ],
              if (_dbPath != null) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storage,
                      size: 14,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _dbPath!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
