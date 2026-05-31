# Database Enhancement — Task Plan

> **Created**: 2026-05-31  
> **Scope**: User-customisation tables, saved-search persistence, tag-filter UX  
> **Principle**: User data MUST NOT be cascade-deleted when models/versions are removed.

---

## 🎯 Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     DATABASE LAYER                              │
├──────────────────────┬──────────────────────────────────────────┤
│  EXISTING (CivitAI)  │  NEW (User Customisation)                │
│                      │                                          │
│  creator             │  user_custom_preview   (1:1 per version) │
│  model_type          │  user_custom_tag       (free-text tags)  │
│  tag                 │  user_note             (file-based md) │
│  model               │  saved_search          (filter presets)  │
│  model_tags          │                                          │
│  base_model          │                                          │
│  base_model_type     │                                          │
│  model_version       │                                          │
│  model_version_file  │                                          │
│  model_version_image │                                          │
└──────────────────────┴──────────────────────────────────────────┘
```

---

## 📋 Task Breakdown

### Phase 1 — New Tables & DAOs

| # | Task | File(s) | Status |
|---|------|---------|--------|
| 1.1 | `user_custom_preview` table DDL | `tables.dart` | ✅ |
| 1.2 | `user_custom_tag` table DDL | `tables.dart` | ✅ |
| 1.3 | `user_note` replaced by file-based markdown notes | `services/file_layout.dart` | ✅ |
| 1.4 | `saved_search` table DDL | `tables.dart` | ✅ |
| 1.5 | Register all new statements in `allCreateStatements` | `tables.dart` | ✅ |
| 1.6 | `UserCustomPreviewDao` — CRUD | `dao/user_custom_preview_dao.dart` | ✅ |
| 1.7 | `UserCustomTagDao` — CRUD + search | `dao/user_custom_tag_dao.dart` | ✅ |
| 1.8 | `UserNoteDao` — removed (replaced by file I/O) | `dao/` (deleted) | ✅ |
| 1.9 | `SavedSearchDao` — CRUD | `dao/saved_search_dao.dart` | ✅ |
| 1.10 | Export new DAOs from `db.dart` | `db.dart` | ✅ |
| 1.11 | Update `SCHEMA.md` with new tables | `SCHEMA.md` | ✅ |

### Phase 2 — Unit Tests

| # | Task | File(s) | Status |
|---|------|---------|--------|
| 2.1 | `user_custom_preview` insert & query | `test/db/db_test.dart` | ✅ |
| 2.2 | `user_custom_tag` CRUD + free-text | `test/db/db_test.dart` | ✅ |
| 2.3 | Markdown note file paths (no unit test needed) | — | ⬜ |
| 2.4 | `saved_search` save & load JSON round-trip | `test/db/db_test.dart` | ✅ |
| 2.5 | Verify user data survives model deletion | `test/db/db_test.dart` | ✅ |

### Phase 3 — File Layout & I/O

| # | Task | File(s) | Status |
|---|------|---------|--------|
| 3.1 | Add `getUserCustomPreviewsDir()` helper | `services/file_layout.dart` | ✅ |
| 3.2 | Add `getUserCustomPreviewPath()` helper | `services/file_layout.dart` | ✅ |

### Phase 4 — UI Integration (future PR)

| # | Task | File(s) | Status |
|---|------|---------|--------|
| 4.1 | Tag autocomplete in FilterPanel via `TagDao.search()` | `ui/local_models/filter_panel.dart` | ✅ |
| 4.2 | Load user custom data on model detail page | `ui/local_models/model_detail_page.dart` | ✅ |
| 4.3 | Saved search CRUD UI (save / load / delete presets) | `ui/local_models/` | ⬜ |
| 4.4 | Custom cover image picker & preview | `ui/local_models/` | ⬜ |
| 4.5 | Custom tags editor | `ui/local_models/` | ⬜ |
| 4.6 | Note viewer — reads `.md` files, renders via WebView | `ui/local_models/markdown_note_viewer.dart` | ✅ |

---

## 🔧 Schema Design

### 1. `user_custom_preview`

One custom cover image per model version.

```sql
CREATE TABLE IF NOT EXISTS user_custom_preview (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  model_id         INTEGER NOT NULL,
  model_version_id INTEGER NOT NULL UNIQUE,
  file_hash        TEXT    NOT NULL,  -- SHA256 for integrity check
  file_name        TEXT    NOT NULL,  -- e.g. "my_cover.png"
  format_suffix    TEXT    NOT NULL,  -- png / jpg / webp
  created_at       TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at       TEXT    NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_user_custom_preview_model
  ON user_custom_preview(model_id);
CREATE INDEX IF NOT EXISTS idx_user_custom_preview_version
  ON user_custom_preview(model_version_id);
```

File path:  
`{basePath}/user_custom/previews/{modelId}_{versionId}.{format_suffix}`

> **No FK → model / model_version**: survives model deletion.

---

### 2. `user_custom_tag`

Free-text tags added by the user. Displayed **separately** from CivitAI official tags on the detail page.

```sql
CREATE TABLE IF NOT EXISTS user_custom_tag (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  model_id         INTEGER NOT NULL,
  model_version_id INTEGER NOT NULL,
  tag_name         TEXT    NOT NULL,
  created_at       TEXT    NOT NULL DEFAULT (datetime('now')),
  UNIQUE(model_version_id, tag_name)
);
CREATE INDEX IF NOT EXISTS idx_user_custom_tag_version
  ON user_custom_tag(model_version_id);
CREATE INDEX IF NOT EXISTS idx_user_custom_tag_name
  ON user_custom_tag(tag_name COLLATE NOCASE);
```

> **No FK → model / model_version**: survives model deletion.

---

### 3. `user_note` — file-based (not in DB)

Markdown notes stored as plain `.md` files — no database table needed.

| Level | File path |
|-------|-----------|
| Model-level | `{basePath}/user_custom/markdown_notes/{modelId}.md` |
| Version-level | `{basePath}/user_custom/markdown_notes/{modelId}_{versionId}.md` |

> Simple file I/O. No DB migration. Survives model deletion automatically.

---

### 4. `saved_search`

Stores filter presets matching `ModelFilters` fields exactly.

```sql
CREATE TABLE IF NOT EXISTS saved_search (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  name       TEXT    NOT NULL UNIQUE,   -- user-given name
  json       TEXT    NOT NULL DEFAULT '{}',  -- filter payload
  created_at TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT    NOT NULL DEFAULT (datetime('now'))
);
```

JSON structure (mirrors `ModelFilters` from `filter_panel.dart`):

```json
{
  "query": "VSK",
  "username": "LeonDoesntDraw",
  "types": ["LORA", "Checkpoint"],
  "baseModels": ["SDXL"],
  "tags": ["anime", "character"],
  "nsfw": false
}
```

| Field | Type | Notes |
|-------|------|-------|
| `query` | `string?` | Fuzzy match on model name |
| `username` | `string?` | Exact match on creator username |
| `types` | `string[]` | Model type filter |
| `baseModels` | `string[]` | Base model filter |
| `tags` | `string[]` | Tag filter |
| `nsfw` | `bool?` | `null` = "All", `true` = Yes, `false` = No |

---

## 🗂 File Layout Additions

```dart
// file_layout.dart additions

/// `{basePath}/user_custom/previews`
String getUserCustomPreviewsDir(String basePath) =>
    p.join(p.normalize(basePath), 'user_custom', 'previews');

/// `{basePath}/user_custom/previews/{modelId}_{versionId}.{format_suffix}`
String getUserCustomPreviewPath(
  String basePath,
  int modelId,
  int versionId,
  String formatSuffix,
) => p.join(
  getUserCustomPreviewsDir(basePath),
  '${modelId}_$versionId.$formatSuffix',
);
```

---

## 🏷 Naming Conventions

| Prefix | Meaning |
|--------|---------|
| (no prefix) | CivitAI official data, cascade-deleted |
| `user_` | User customisation data, preserved on model deletion |

---

## ⚠️ Key Decisions

| Decision | Rationale |
|----------|-----------|
| No FK cascade on user tables | User custom data survives model deletion ("后悔的机会") |
| `user_custom_preview` 1:1 per version | One cover image per version, `model_version_id UNIQUE` |
| `user_custom_tag` free-text | Not limited to official CivitAI tags |
| `user_note` dual-level via partial indexes | File-based — `{basePath}/user_custom/markdown_notes/{id}.md` and `{modelId}_{versionId}.md` |
| `saved_search.json` TEXT | Flexible schema, matches `ModelFilters` exactly |
| `model_version_id` in all user tables | Enables loading all custom data for a version in one query batch |

---

## 📝 Notes

- Phase 1–3 can be done in one PR; Phase 4 (UI) is a separate follow-up.
- `TagDao.search()` already supports `LIKE '%keyword%'` — ready for tag autocomplete.
- All new tables have no FK constraints, so `deleteVersion()` needs zero changes.
- `upsertVersion()` needs zero changes — it only touches CivitAI official tables.
