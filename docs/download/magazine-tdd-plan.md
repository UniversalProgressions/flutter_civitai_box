# Magazine Download System — TDD Implementation Plan

> "Red → Green → Refactor" for every unit.
> Tests written **before** production code. One component at a time.

**Progress: 98 tests written, 92 verified GREEN (2026-06-07)**
✅ Phase 1-4 complete | 🔨 Phase 5 partial (widget tests pending `flutter test` env fix) | ⬜ Phase 6 remaining

---

## Testing Conventions (from existing codebase)

| Convention | Detail |
|------------|--------|
| **Test runner** | `package:test/test.dart` (not `flutter_test`) |
| **SQLite** | `sqflite_common_ffi` + `databaseFactoryFfi` with `:memory:` path |
| **Mocking** | `package:mocktail` ^1.0.4 |
| **Fixtures** | JSON files in `test/data/` loaded via `dart:io` `File.readAsStringSync()` |
| **DB lifecycle** | `setUp` → `CivitaiDatabase.initForTest(':memory:')` / `tearDown` → `close()` |
| **File naming** | `*_test.dart` suffix |
| **Group structure** | `group('ComponentName', () { test('does X', () async { ... }); })` |

---

## Phases

### Phase 1 — Pure Data Models (no dependencies)

**What**: `MagazineItem`, `MagazineItemStatus`, `LoadResult`, `LoadError`, `LoadErrorType`, `FireEvent`, `FireSummary`

These are pure Dart classes — no SQLite, no API, no Flutter. Fastest tests.

| Step | Test File | Tests to Write | Production File |
|------|-----------|----------------|-----------------|
| 1.1 | `test/download/magazine_item_test.dart` | `MagazineItem.fromRow()` parses valid SQLite row<br>`MagazineItem.fromRow()` throws on missing required fields<br>`MagazineItem.toRow()` produces correct column map<br>`MagazineItem.toRow()` round-trips with `fromRow()` | `lib/services/download/download_magazine_item.dart` |
| 1.2 | (same file) | `MagazineItemStatus.values` has exactly `[pending, firing, failed, skipped]`<br>Status enum serialization/deserialization | (same file) |
| 1.3 | `test/download/load_result_test.dart` | `LoadResult.ok(item)` pattern matches as `LoadOk`<br>`LoadResult.error(err)` pattern matches as `LoadError_`<br>`LoadError` has correct `type`, `message`, `detail` fields<br>`LoadErrorType` has all expected variants | `lib/services/download/download_magazine_item.dart` (add `LoadResult`) |
| 1.4 | `test/download/fire_event_test.dart` | `FireEvent.roundStarted(item)` pattern matches<br>`FireEvent.retrying(item, 2, 'reason')` pattern matches<br>`FireEvent.roundCompleted(123, 'Name')` pattern matches<br>`FireEvent.roundSkipped(item)` pattern matches<br>`FireEvent.jammed(item)` pattern matches<br>`FireEvent.done(summary)` pattern matches<br>`FireSummary` equality works correctly | `lib/services/download/download_magazine_item.dart` (add `FireEvent`) |

> **TDD Cycle**: For each test: write test → run (RED) → implement → run (GREEN) → commit.

---

### Phase 2 — Magazine Database (SQLite)

**What**: `DownloadMagazineDatabase` — CRUD against `download_magazine` table.

Dependency: `CivitaiDatabase` (needs migration for the new table).

| Step | Test File | Tests to Write | Production File |
|------|-----------|----------------|-----------------|
| 2.1 | `test/download/download_magazine_database_test.dart` | `insert()` persists a row and returns it<br>`insert()` rejects duplicate `model_version_id` (UNIQUE constraint)<br>`findByModelVersionId()` finds existing, returns null for missing | `lib/services/download/download_magazine_database.dart`<br>`lib/db/database.dart` (migration) |
| 2.2 | (same file) | `loadAll()` returns all rows ordered by `id`<br>`loadPending()` returns only `status='pending'` rows<br>`loadFiring()` returns `status='firing'` row (null if none)<br>`findFiringRound()` returns the firing row (alias for `loadFiring`) | (same files) |
| 2.3 | (same file) | `update()` changes status, retry_count, error_message<br>`update()` persists changes across DB close/reopen<br>`resetFiringToPending()` sets status='pending' preserving retry_count | (same files) |
| 2.4 | (same file) | `remove()` deletes a row<br>`remove()` is idempotent for non-existent rows (or throws — decide)<br>`delete()` deletes a row<br>`clear()` removes all non-firing rows<br>`clear()` leaves firing row untouched | (same files) |
| 2.5 | (same file) | Table migration creates `download_magazine` with correct schema<br>Migration is idempotent (running twice does not crash) | `lib/db/database.dart` |

> **TDD Cycle**: Migration test first → add migration → CRUD tests → implement each method.

---

### Phase 3 — `load()` Function (API + Validation + Persist)

**What**: `DownloadMagazineResolver.load()` — the public Load API.

Dependencies: `CivitaiApiClient` (mocked), `DownloadMagazineDatabase` (real, in-memory).

**Test data needed**: Create `test/data/magazine/` with:

- `model_version_123456.json` — valid `ModelVersionEndpointData` response
- `model_789.json` — valid model response
- `model_version_no_files.json` — version with empty `files` array
- `model_version_missing_modelId.json` — version without `modelId` field

| Step | Test File | Tests to Write | Production File |
|------|-----------|----------------|-----------------|
| 3.1 | `test/download/download_magazine_resolver_test.dart` | `load()` with valid ID returns `LoadResult.ok` with correct parsed fields<br>`load()` sets `model_name`, `version_name`, `base_model`, `model_type` from API data<br>`load()` serializes `model_json` and `version_json` correctly<br>`load()` calculates `file_count` and `total_size_kb` correctly | `lib/services/download/download_magazine_resolver.dart` |
| 3.2 | (same file) | `load()` rejects non-positive integer → `LoadError(invalidId)`<br>`load()` rejects duplicate (already in magazine) → `LoadError(alreadyInMagazine)` | (same file) |
| 3.3 | (same file) | `load()` on API network error → `LoadError(networkError)`<br>`load()` on API 404 → `LoadError(apiError)` with status code<br>`load()` on API 403 → `LoadError(apiError)`<br>`load()` on API 500 → `LoadError(apiError)` | (same file) |
| 3.4 | (same file) | `load()` on version response missing `modelId` → `LoadError(validationError)`<br>`load()` on version response with no files → `LoadError(validationError)`<br>`load()` on model response missing `name` → `LoadError(validationError)` | (same file) |
| 3.5 | (same file) | `load()` on model endpoint failure after successful version fetch → `LoadError(apiError)` (version data NOT persisted — atomic) | (same file) |

> **Mocking pattern**: Use `mocktail` to mock `CivitaiApiClient` and its `.modelVersions.getById()` / `.models.getById()` methods.

---

### Phase 4 — `fire()` Function (Sequential Download Engine)

**What**: `DownloadMagazineResolver.fire()` — the public Fire API.

Dependencies: `DownloadMagazineDatabase` (real), `DownloadQueue` (mocked), `CivitaiApiClient` (mocked for URL resolution), FileSystem (real temp dir or mocked).

This is the most complex phase. Break into sub-phases.

#### 4A — Fire: Basic Happy Path

| Step | Test File | Tests to Write |
|------|-----------|----------------|
| 4.1 | `test/download/download_magazine_resolver_test.dart` (same file) | `fire()` with empty magazine emits only `FireEvent.done(zeros)` |
| 4.2 | (same file) | `fire()` with one pending round: emits `roundStarted` → `roundCompleted` → `done(1,0,0)` |
| 4.3 | (same file) | `fire()` with three pending rounds: processes all three sequentially, emits correct events, final `done(3,0,0)` |
| 4.4 | (same file) | `fire()` deletes rounds from DB on success (verify via `loadAll().length == 0`) |
| 4.5 | (same file) | `fire()` writes JSON files to disk on success<br>`fire()` upserts to local DB on success |

#### 4B — Fire: Retry Logic

| Step | Test File | Tests to Write |
|------|-----------|----------------|
| 4.6 | (same file) | `fire()` on 1st failure: increments `retry_count` to 1, resets status to `pending`, emits `retrying`, retries |
| 4.7 | (same file) | `fire()` on 2nd failure: increments `retry_count` to 2, resets to `pending`, emits `retrying`, retries again |
| 4.8 | (same file) | `fire()` on 3rd failure: increments `retry_count` to 3, sets status to `failed`, emits `jammed`, STOPS |
| 4.9 | (same file) | `fire()` after jam: subsequent `pending` rounds are NOT processed (verify `pending` count unchanged) |
| 4.10 | (same file) | `fire()` retry count persists across `fire()` calls (not reset on new fire) |

#### 4C — Fire: Unjam

| Step | Test File | Tests to Write |
|------|-----------|----------------|
| 4.11 | (same file) | `skipFailedRound()` changes status to `skipped` |
| 4.12 | (same file) | `fire()` after skip: continues to next `pending` round, emits `roundSkipped` in summary |
| 4.13 | (same file) | `retryFailedRound()` resets `retry_count` to 0, status to `pending` |
| 4.14 | (same file) | `fire()` after retry-failed-round: processes the previously-failed round with fresh retry count |

#### 4D — Fire: Crash Recovery

| Step | Test File | Tests to Write |
|------|-----------|----------------|
| 4.15 | (same file) | `findFiringRound()` finds a round stuck in `firing` |
| 4.16 | (same file) | `resetFiringToPending()` resets it while preserving `retry_count` |
| 4.17 | (same file) | Recovery flow: simulate crash (round=firing), reset, then `fire()` continues normally |

#### 4E — Fire: Deduplication

| Step | Test File | Tests to Write |
|------|-----------|----------------|
| 4.18 | (same file) | `fire()` skips round if files already exist on disk (JSON marker files present) |
| 4.19 | (same file) | `fire()` skips round if DownloadQueue already has active batch for that version |

> **Mocking pattern for Fire**: Mock `DownloadQueue.instance` to simulate batch completion/failure. Mock `CivitaiApiClient.modelVersions.resolveFileDownloadUrl()`. Use `package:file/memory.dart` MemoryFileSystem for JSON file writes to avoid real disk I/O in tests.

---

### Phase 5 — UI Components (Widget Tests)

**What**: `MagazineItemTile`, `DownloadMagazineTab`, integration into `DownloadPage`.

| Step | Test File | Tests to Write | Production File |
|------|-----------|----------------|-----------------|
| 5.1 | `test/download/magazine_item_tile_test.dart` | Renders `pending` round with correct icon, model name, version name<br>Renders `firing` round with spinner<br>Renders `failed` round with error message and [Skip][Retry] buttons<br>Renders `skipped` round with "Skipped" text<br>Unload button triggers callback | `lib/ui/download/widgets/magazine_item_tile.dart` |
| 5.2 | `test/download/download_magazine_tab_test.dart` | Load button disabled when input is empty<br>Load button disabled when input is non-integer<br>Fire button disabled when magazine is empty<br>Renders list of magazine items from state<br>Unload All shows confirmation dialog | `lib/ui/download/download_magazine_tab.dart` |
| 5.3 | `test/download/download_page_test.dart` | TabBar shows both Fetch and Magazine tabs<br>Switching tabs preserves state<br>Queue section visible in both tabs | `lib/ui/download/download_page.dart` (modified) |

> **Widget test pattern**: `pumpWidget(MaterialApp(home: Scaffold(body: WidgetUnderTest)))`, use `pump()` for async, `Finder` for widget lookup.

---

### Phase 6 — Integration / End-to-End

| Step | Test File | Tests to Write |
|------|-----------|----------------|
| 6.1 | `test/download/magazine_integration_test.dart` | Load → Fire → Verify JSON files on disk → Verify DB records |
| 6.2 | (same file) | Load → Fire with failure → Retry 3x → Jam → Unjam(skip) → Continue |
| 6.3 | (same file) | App restart simulation: Load rounds → kill during Fire → recover → Fire continues |

> These could use real API calls against a test CivitAI endpoint, or comprehensive mocks.

---

## Execution Order Summary

```
Phase 1: Data Models     ✅ 54 tests  — MagazineItem, LoadResult, FireEvent
Phase 2: Database CRUD   ✅ 11 tests  — download_magazine table + CRUD
Phase 3: load()          ✅ 13 tests  — API fetch, validate, persist
Phase 4: fire()          ✅  9 tests  — Sequential processing, retry, jam
Phase 5: UI              🔨 11 tests  — MagazineItemTile, DownloadMagazineTab
Phase 6: Integration     ⬜ remaining — Production wiring, DownloadPage refactor
                       ─────
                       98 tests total (92 GREEN via dart test, 6 widget tests pending flutter test env fix)
```

| Phase | Tests | Runner | Key Files |
|-------|-------|--------|-----------|
| 1. Data Models | 54 | `dart test` | `download_magazine_item.dart` |
| 2. Database | 11 | `flutter test` | `download_magazine_database.dart`, `tables.dart`, `database.dart` |
| 3. `load()` | 13 | `flutter test` | `download_magazine_resolver.dart` |
| 4. `fire()` | 9 | `flutter test` | `download_magazine_resolver.dart` |
| 5. UI | 11 | `flutter test` | `magazine_item_tile.dart`, `download_magazine_tab.dart` |
| 6. Integration | — | — | `DownloadPage`, production wiring |

### Remaining

- [ ] `DownloadPage` TabBar refactoring (Fetch tab extraction + Magazine tab integration)
- [ ] Production `downloadRound` wiring (real `DownloadQueue`, JSON file writes, `ModelRefreshBus`)
- [ ] Crash recovery in `main()` (reset `firing` round, delete orphaned tasks)
- [ ] Rust FFI expose `load()` and `fire()` via `flutter_rust_bridge`

---

## Test Fixtures

Created in `test/data/magazine/`:

| File | Contents | Status |
|------|----------|--------|
| `model_version_123456.json` | Complete ModelVersionEndpointData response with 2 files + 2 images | ✅ Created |
| `model_789.json` | Model endpoint response (Checkpoint, creator, tags) | ✅ Created |
| `model_version_no_files.json` | Version response with empty files/images | ✅ Created |
| `model_version_minimal.json` | Version with 1 model file, 0 images | ⬜ Not needed yet |

---

## Notes

- **No test should use a real network connection.** All API calls are mocked via `mocktail`.
- **Database tests use `:memory:`** — fast, isolated, `setUp`/`tearDown` with `initForTest`.
- **`fire()` uses injectable `downloadRound` callback** — tests mock the download step without touching `DownloadQueue`.
- **`DownloadMagazineTab` accepts `initialRounds`** for testability — sync widget tests, no async DB in `initState`.
- **`CivitaiApiClient.withDio()` constructor** added for Dio injection in tests.
- Commit after each passing test step for clean git history.
