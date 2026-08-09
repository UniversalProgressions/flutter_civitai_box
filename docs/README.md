# CivitAI Box — Documentation

> Central index for project architecture and design documentation.

---

## 🗺 Architecture Overview

```txt
┌──────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  CivitAI API │────▶│  SQLite Database │────▶│  Download       │
│  (lib/civitai│     │  (lib/db/)       │     │  System         │
│   _api/)     │     │                  │     │  (lib/services/ │
│              │     │  CivitAI mirror  │     │   download/)    │
│  FP client   │     │  + user custom   │     │                 │
│  dartz Either│     │  tables          │     │  background_    │
│  Freezed DTOs│     │                  │     │  downloader     │
└──────────────┘     └────────┬─────────┘     └────────┬────────┘
                              │                        │
                              ▼                        ▼
                     ┌──────────────────────────────────┐
                     │         File System              │
                     │  {basePath}/{type}/{id}/...      │
                     │  + user_custom/...               │
                     └──────────────────────────────────┘
```

| Layer | Directory | Description |
| ------- | ----------- | ------------- |
| **API Client** | `lib/civitai_api/` | FP-style CivitAI REST client — dartz `Either`, Freezed models, closure DI |
| **Database** | `lib/db/` | SQLite via sqflite — DAO + Repository pattern, CivitAI mirror + user tables |
| **Download** | `lib/services/download/` | Background download queue — batch per ModelVersion, survives app restart |
| **UI** | `lib/ui/` | Download page, local model browser, filter panel, model detail |
| **Services** | `lib/services/` | File layout, hash checking, logging, model refresh bus |

---

## 📄 Documents

### API Client

| Document | Description |
|----------|-------------|
| [API Client Architecture](api-client.md) | FP design decisions, directory structure, core types, endpoint pattern |

### Database

| Document | Description |
|----------|-------------|
| [Database Schema](database/schema.md) | All 14 tables with DDL, ER diagram, type mapping, DAO/Repository architecture |
| [User Customization](database/user-customization.md) | Design rationale for user custom previews, tags, notes, and saved searches |

### Download System

| Document | Description |
|----------|-------------|
| [Download System Design](download/design.md) | Batch-based download queue, file layout, data flow, queue lifecycle, edge cases |

### UI Design

| Document | Description |
|----------|-------------|
| [UI Theming & Animation](ui-theming.md) | NSFW-bound color system (3 palettes), animation strategy, motion tokens |

### Packaging & Release

| Document | Description |
|----------|-------------|
| [Packaging & Release 手册](packaging.md) | 操作手册：Fast Forge 打包 MSIX/DMG/AppImage + 发布到 GitHub Releases |
| [打包完整指南与踩坑记录](packaging-guide.md) | 深度记录：工具链内部结构、完整流程、13 个踩坑及解决方案 |

---

## 🏷 Naming Conventions

| Prefix | Meaning |
|--------|---------|
| (none) | CivitAI official data — cascade-deleted with model/version |
| `user_` | User data — **preserved** on model deletion (no FK cascade) |

---

## 📁 File Layout

```txt
{basePath}/
  {modelType}/                          ← e.g. Checkpoint, LoRA
    {modelId}/
      {modelId}.api-info.json           ← GET /api/v1/models/{modelId}
      {versionId}/
        {versionId}.api-info.json       ← GET /api/v1/model-versions/{versionId}
        files/
          model.safetensors
        media/
          {imageId}.jpeg
  user_custom/
    previews/                           ← Custom cover images
    markdown_notes/                     ← User markdown notes (.md files)
```
