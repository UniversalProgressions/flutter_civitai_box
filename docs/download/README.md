# Download System — Documentation

## Index

| Document | Scope | Status |
|----------|-------|--------|
| [design.md](design.md) | Existing download system — `download_task`, `DownloadQueue`, file layout | ✅ Production |
| [magazine-design.md](magazine-design.md) | Magazine staging system — `load()` / `fire()`, `download_magazine` table, state machine | ✅ Design final |
| [magazine-tdd-plan.md](magazine-tdd-plan.md) | TDD implementation phases with test counts per step | 🔨 ~92% done |
| [magazine-integration.md](magazine-integration.md) | How magazine connects to existing code — wiring, crash recovery, data flow | 📝 Reference |

## Quick Reference

### Where is what?

| I want to... | Read |
|--------------|------|
| Understand the existing download system | [design.md](design.md) |
| Understand the magazine metaphor & data model | [magazine-design.md](magazine-design.md) |
| See what's implemented and what's left | [magazine-tdd-plan.md](magazine-tdd-plan.md) |
| Know how to wire magazine into the app | [magazine-integration.md](magazine-integration.md) |

### Architecture at a Glance

```
docs/download/
├── README.md                   ← This file
├── design.md                   ← Existing download system (download_task, DownloadQueue)
├── magazine-design.md          ← Magazine design (load/fire, schema, state machine)
├── magazine-tdd-plan.md        ← TDD plan with progress tracking
└── magazine-integration.md     ← Integration guide (wiring, recovery, FFI)
```

### Key Files (Implementation)

```
lib/services/download/
├── download_task.dart              — (existing) DownloadTask, DownloadQueueState
├── download_database.dart          — (existing) download_task CRUD
├── download_queue.dart             — (existing) Queue engine
├── download_magazine_item.dart     — (new) MagazineItem, LoadResult, FireEvent
├── download_magazine_database.dart — (new) download_magazine CRUD
└── download_magazine_resolver.dart — (new) load() + fire() public API

lib/ui/download/
├── download_page.dart              — (modify) Add TabBar
├── download_fetch_tab.dart         — (refactor) Extract existing Fetch
├── download_magazine_tab.dart      — (new) Magazine tab UI
└── widgets/
    ├── download_batch_card.dart    — (existing)
    ├── download_task_tile.dart     — (existing)
    └── magazine_item_tile.dart     — (new) Single round row

test/download/
├── magazine_item_test.dart         — 25 tests
├── load_result_test.dart           — 12 tests
├── fire_event_test.dart            — 17 tests
├── download_magazine_database_test.dart — 11 tests
├── download_magazine_resolver_test.dart — 22 tests
├── magazine_item_tile_test.dart    — 5 tests
└── download_magazine_tab_test.dart — 6 tests
```
