import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'settings/nsfw_settings.dart';
import 'settings/settings.dart';
import 'services/download/download_queue.dart';
import 'ui/download/download_page.dart';
import 'ui/local_models/local_models_page.dart';
import 'ui/settings/settings_page.dart';
import 'ui/stats/stats_page.dart';
import 'ui/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  await DownloadQueue.instance.init();
  await NsfwSettings.getInstance(); // init & restore persisted mode
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final NsfwSettings _nsfwSettings;

  @override
  void initState() {
    super.initState();
    _nsfwSettings = NsfwSettings.instance!;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _nsfwSettings,
      builder: (context, _) {
        return MaterialApp(
          title: 'CivitAI Box',
          debugShowCheckedModeBanner: false,
          theme: themeForMode(NsfwFilter.all),
          home: AnimatedTheme(
            data: themeForMode(_nsfwSettings.mode),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: const AppShell(),
          ),
        );
      },
    );
  }
}

/// Decides whether to show the settings wizard or the main app.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late Future<bool> _hasSettings;

  @override
  void initState() {
    super.initState();
    _hasSettings = SettingsService.getInstance().then((s) => s.hasSettings);
  }

  void _onSettingsSaved() {
    _hasSettings = Future.value(true);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasSettings,
      builder: (context, snapshot) {
        // While loading, show a splash
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final configured = snapshot.data!;
        if (!configured) {
          return SettingsPage(isFirstLaunch: true, onSaved: _onSettingsSaved);
        }

        return const MainShell();
      },
    );
  }
}

/// Bottom-navigation shell after settings are configured.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const <Widget>[
    LocalModelsPage(),
    DownloadPage(),
    StatsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark),
            label: 'Local Models',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_download),
            label: 'Download',
          ),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
