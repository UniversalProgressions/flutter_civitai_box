# Magazine Download System — Integration Guide

> How the magazine system connects to the existing download infrastructure.

---

## Architecture Layers

```
┌──────────────────────────────────────────────────────┐
│                      UI Layer                         │
│  ┌─────────────────┐  ┌──────────────────────────┐  │
│  │ DownloadFetchTab │  │ DownloadMagazineTab       │  │
│  │ (existing, kept) │  │ (new)                     │  │
│  │                  │  │  ├─ Input + Load button   │  │
│  │                  │  │  ├─ Round list             │  │
│  │                  │  │  ├─ Fire button            │  │
│  │                  │  │  └─ Status bar             │  │
│  └─────────────────┘  └──────────┬───────────────┘  │
│                                  │                   │
│  ┌───────────────────────────────┴───────────────┐  │
│  │ DownloadPage (TabBar + shared Queue section)   │  │
│  └───────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
                          │
┌─────────────────────────┼──────────────────────────┐
│                    Engine Layer                      │
│                                                      │
│  download_magazine_resolver.dart                     │
│  ├─ load(versionId, api) → LoadResult                │
│  └─ fire(magazineDb, downloadRound) → Stream<FireEvent>
│                                                      │
│  download_queue.dart (existing, unchanged)            │
│  └─ enqueueBatch() / stateStream                     │
└─────────────────────────┬────────────────────────────┘
                          │
┌─────────────────────────┼────────────────────────────┐
│                   Data Layer                          │
│                                                       │
│  download_magazine  ←→  download_task                 │
│  (staging/planning)      (execution/progress)          │
│                                                       │
│  download_magazine_database.dart                      │
│  └─ CRUD + unjam methods                              │
│                                                       │
│  download_database.dart (existing)                     │
│  download_task.dart (existing)                         │
└───────────────────────────────────────────────────────┘
```

---

## Component Wiring

### 1. `DownloadMagazineTab` State

The `DownloadMagazineTab` is a `StatefulWidget` that manages:

```dart
class _DownloadMagazineTabState extends State<DownloadMagazineTab> {
  final _idCtrl = TextEditingController();
  final _magazineDb = const DownloadMagazineDatabase();
  final _api = /* CivitaiApiClient from settings */;
  
  List<MagazineItem> _rounds = [];
  bool _isLoading = false;    // Load in progress
  bool _isFiring = false;     // Fire in progress
  String? _statusText;        // "✅ 3 done · ❌ 1 jammed"
  StreamSubscription<FireEvent>? _fireSub;
  
  @override
  void initState() {
    super.initState();
    _loadRounds(); // Restore from DB
  }
  
  Future<void> _loadRounds() async {
    _rounds = await _magazineDb.loadAll();
    setState(() {});
  }
  
  Future<void> _onLoad() async {
    final id = int.tryParse(_idCtrl.text);
    if (id == null) return;
    
    setState(() => _isLoading = true);
    final result = await load(modelVersionId: id, api: _api);
    setState(() => _isLoading = false);
    
    switch (result) {
      case LoadOk(:final item):
        _idCtrl.clear();
        await _loadRounds();
      case LoadError_(:final error):
        _showError(error.message);
    }
  }
  
  Future<void> _onFire() async {
    setState(() => _isFiring = true);
    
    final events = fire(
      magazineDb: _magazineDb,
      downloadRound: _productionDownloadRound,
    );
    
    await for (final event in events) {
      switch (event) {
        case FireRoundStarted():
          // Update UI: mark round as firing
        case FireRetrying():
          // Update UI: show retry
        case FireRoundCompleted():
          await _loadRounds(); // Refresh list (round deleted)
        case FireJammed():
          await _loadRounds(); // Show failed state
        case FireDone(:final summary):
          _statusText = '✅ ${summary.completed} done · ❌ ${summary.failed} jammed';
      }
      if (mounted) setState(() {});
    }
    
    setState(() => _isFiring = false);
  }
}
```

### 2. Production `downloadRound` Callback

The `fire()` function accepts an injectable `downloadRound` callback. In production, this is wired to the real `DownloadQueue`:

```dart
Future<bool> _productionDownloadRound(MagazineItem item) async {
  // 1. Parse JSON blobs from magazine
  final versionJson = jsonDecode(item.versionJson) as Map<String, dynamic>;
  final modelJson = jsonDecode(item.modelJson) as Map<String, dynamic>;
  
  // 2. Resolve file download URLs (embed auth token)
  final files = (versionJson['files'] as List?) ?? [];
  final images = (versionJson['images'] as List?) ?? [];
  
  final resolvedUrls = <String>[];
  for (final file in [...files, ...images]) {
    final url = file['downloadUrl'] ?? file['url'];
    if (url != null) {
      final resolved = await api.modelVersions.resolveFileDownloadUrl(url);
      resolvedUrls.add(resolved);
    }
  }
  
  // 3. Build DownloadTask objects
  final batchId = 'magazine-${item.modelVersionId}-${DateTime.now().millisecondsSinceEpoch}';
  final modelTasks = /* build from files */;
  final mediaTasks = /* build from images */;
  
  // 4. Enqueue to DownloadQueue
  await DownloadQueue.instance.enqueueBatch(
    batchId: batchId,
    apiJsonTasks: [],   // No apiJson tasks — written at the end
    modelTasks: modelTasks,
    mediaTasks: mediaTasks,
  );
  
  // 5. Wait for batch completion
  final completer = Completer<bool>();
  StreamSubscription<DownloadQueueState>? sub;
  
  sub = DownloadQueue.instance.stateStream.listen((state) {
    final batch = state.batches[batchId];
    if (batch == null) return; // Batch not yet loaded
    
    if (batch.tasks.every((t) => t.status == DownloadTaskStatus.completed)) {
      // Success — write JSON files & cleanup
      _writeJsonFiles(item.modelId, modelJson, item.modelVersionId, versionJson);
      sub?.cancel();
      completer.complete(true);
    } else if (batch.tasks.any((t) => t.status == DownloadTaskStatus.failed || 
                                t.status == DownloadTaskStatus.cancelled)) {
      sub?.cancel();
      completer.complete(false);
    }
  });
  
  return completer.future;
}
```

### 3. Crash Recovery on App Startup

In `main()` or the magazine tab's `initState()`, add recovery logic:

```dart
Future<void> _recoverFromCrash() async {
  final db = const DownloadMagazineDatabase();
  final firing = await db.findFiringRound();
  if (firing == null) return; // Clean state
  
  // Reset the firing round to pending
  await db.resetFiringToPending(firing.id);
  
  // Delete orphaned download_task entries
  final existingDb = await CivitaiDatabase.instance;
  await existingDb.db.delete(
    'download_task',
    where: 'model_version_id = ? AND status IN (?, ?)',
    whereArgs: [firing.modelVersionId, 'pending', 'downloading'],
  );
  
  log.info('Magazine crash recovery: reset round ${firing.modelVersionId}');
}
```

### 4. DownloadPage TabBar Integration

```dart
// In _DownloadPageState:

@override
Widget build(BuildContext context) {
  return DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Download'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Fetch'),
            Tab(text: 'Magazine'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              children: [
                DownloadFetchTab(/* existing fetch logic */),
                const DownloadMagazineTab(),
              ],
            ),
          ),
          // Shared queue section
          _buildQueueSection(),
        ],
      ),
    ),
  );
}
```

### 5. Fetch Tab Extraction (Refactor)

The existing `DownloadPage` logic is extracted into `DownloadFetchTab`:

```dart
class DownloadFetchTab extends StatefulWidget {
  const DownloadFetchTab({super.key});
  @override
  State<DownloadFetchTab> createState() => _DownloadFetchTabState();
}

// Move existing: _FetchMode, _idCtrl, _model, _versionDetails,
// _selectedVersionIds, _fetchModel(), _fetchVersion(), _startDownload()
// from _DownloadPageState into _DownloadFetchTabState.
// Keep _queueState subscription in DownloadPage (shared).
```

---

## Data Flow: Load → Review → Fire → Complete

```
1. LOAD
   User enters version ID → taps "Load"
   → load(versionId, api)
   → CivitAI API: GET /model-versions/{id} + GET /models/{modelId}
   → Parse display fields + serialize JSON
   → INSERT INTO download_magazine
   → UI shows round with model name, type, file count, size
   
2. REVIEW
   User inspects rounds in magazine list
   → Can unload (remove) any pending/skipped round
   → Can skip or retry any failed round
   
3. FIRE
   User taps "Fire"
   → fire(magazineDb, downloadRound)
   → For each pending round, sequentially:
     a. Mark firing
     b. Parse JSON → build DownloadTask objects
     c. DownloadQueue.enqueueBatch()
     d. Wait for all tasks to complete
     e. On success: write JSON files to disk, DELETE magazine row
     f. On failure: retry up to 3x, then JAM
   → UI updates via FireEvent stream
   
4. COMPLETE
   Magazine table is empty (all rounds deleted on success)
   or has failed/skipped rounds (user intervention needed)
   DownloadQueue continues in background (UI shows progress)
```

---

## Database Relationship

```
download_magazine                    download_task
─────────────────                    ─────────────
id (PK)                              id (PK)
model_version_id (UNIQUE)            batch_id
model_id                             model_id
model_name                           model_version_id
version_name                         file_name
base_model                           file_size_kb
model_type                           download_url
file_count                           target_path
total_size_kb                        file_type (model/media/api_json)
model_json (TEXT)                    status (pending/downloading/completed/...)
version_json (TEXT)                  progress (0.0 ~ 1.0)
status (pending/firing/failed/skipped)
retry_count
error_message
loaded_at
fired_at

Relationship:
  Fire reads download_magazine.model_json + version_json
  → builds download_task rows
  → enqueues via DownloadQueue.enqueueBatch()
  → on success: DELETE FROM download_magazine
  → on failure: retry or jam (UPDATE download_magazine.status)
  
No FK between tables. They are independent layers.
```

---

## Test Architecture

```
Test type              | Runner       | DB          | API      | DownloadQueue
───────────────────────┼──────────────┼─────────────┼──────────┼──────────────
Phase 1: Data Models   | dart test    | None        | N/A      | N/A
Phase 2: DB CRUD       | flutter test | :memory:    | N/A      | N/A
Phase 3: load()        | flutter test | :memory:    | Mock Dio | N/A
Phase 4: fire()        | flutter test | :memory:    | N/A      | Injected cb
Phase 5: Widgets       | flutter test | N/A         | N/A      | N/A
Phase 6: Integration   | flutter test | :memory:    | Mock Dio | Real (TBD)
```

The `downloadRound` injectable callback is the key testability seam:

- Tests: `fire(magazineDb: db, downloadRound: (item) async => true/false)`
- Production: `fire(magazineDb: db, downloadRound: _productionDownloadRound)`

---

## Integration Steps

1. ✅ **Extract `DownloadFetchTab`** — Move existing fetch logic from `DownloadPage` into a standalone widget (pure refactor, no behavior change)
2. ✅ **Create `DownloadMagazineTab`** — Stateful widget with input, round list, Fire button, status bar
3. ✅ **Update `DownloadPage`** — Add `TabBar` + `TabBarView` with both tabs, shared queue section
4. ✅ **Wire production `downloadRound`** — Connect to real `DownloadQueue`, file writes, `ModelRefreshBus`
5. ✅ **Crash recovery in `main()`** — Call `_recoverMagazineFromCrash()` after DB init
6. ~~**Rust FFI**~~ — **Removed (2026-08-08)**: Rust integration is not planned; `flutter_rust_bridge` dependency removed. See `PROJECT_PROGRESS.md`.
