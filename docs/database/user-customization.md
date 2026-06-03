# User Customization

> Design rationale for user-defined data that augments CivitAI models without being
> tied to CivitAI's lifecycle. User data survives model/version deletion.

---

## Overview

```txt
┌──────────────────────────────────────────────────────────────┐
│                     DATABASE LAYER                           │
├──────────────────────┬───────────────────────────────────────┤
│  EXISTING (CivitAI)  │  NEW (User Customisation)             │
│                      │                                       │
│  creator             │  user_custom_preview (1:1 per version)│
│  model_type          │  user_custom_tag     (free-text tags) │
│  tag                 │  user_note           (file-based md)  │
│  model               │  saved_search        (filter presets) │
│  model_tags          │                                       │
│  base_model          │                                       │
│  base_model_type     │                                       │
│  model_version       │                                       │
│  model_version_file  │                                       │
│  model_version_image │                                       │
└──────────────────────┴───────────────────────────────────────┘
```

---

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| No FK cascade on user tables | User custom data survives model deletion |
| `user_custom_preview` 1:1 per version | One cover image per version, `model_version_id UNIQUE` |
| `user_custom_tag` free-text | Not limited to official CivitAI tags |
| `user_note` file-based | Stored as `.md` files — no DB migration needed, survives deletions |
| `saved_search.json` TEXT | Flexible schema, matches `ModelFilters` exactly |
| `model_version_id` in all user tables | Enables loading all custom data for a version in one query batch |

---

## Tables

### `user_custom_preview`

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
```

File path: `{basePath}/user_custom/previews/{modelId}_{versionId}.{format_suffix}`

---

### `user_custom_tag`

Free-text tags added by the user. Displayed **separately** from CivitAI official tags.

```sql
CREATE TABLE IF NOT EXISTS user_custom_tag (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  model_id         INTEGER NOT NULL,
  model_version_id INTEGER NOT NULL,
  tag_name         TEXT    NOT NULL,
  created_at       TEXT    NOT NULL DEFAULT (datetime('now')),
  UNIQUE(model_version_id, tag_name)
);
```

---

### User Notes (file-based)

Markdown notes stored as plain `.md` files — no database table needed.

| Level | File path |
|-------|-----------|
| Model-level | `{basePath}/user_custom/markdown_notes/{modelId}.md` |
| Version-level | `{basePath}/user_custom/markdown_notes/{modelId}_{versionId}.md` |

> Simple file I/O. No DB migration. Survives model deletion automatically.

---

### `saved_search`

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

## File Layout Additions

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

## Naming Conventions

| Prefix | Meaning |
|--------|---------|
| (no prefix) | CivitAI official data, cascade-deleted |
| `user_` | User customisation data, preserved on model deletion |
