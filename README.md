# CivitAI Box

A desktop application for browsing, managing, and downloading [CivitAI](https://civitai.com) AI model files. Built with Flutter.

## Features

### 📦 Local Model Library

- **Scan local model files** — automatically discover models already on disk
- **Browse by type** (Checkpoint, LoRA, VAE, TextualInversion, etc.) with search, tag, and NSFW filters
- **Detailed model view** — preview images, version tabs, file lists, trigger words, and description panels
- **Markdown notes** — attach Markdown notes at both model and version level

### 📊 Statistics Dashboard

- Model counts by type, base model, creator, and tags
- NSFW/SFW distribution
- File integrity checker — verify SHA256 hashes of downloaded model files

### ⬇️ Download System

- **Fetch by Model ID or Version ID** from the CivitAI API
- **Per-version download** with intelligent batching: model files first (×2), then preview images (×4)
- **Persistent task queue** — survives app restart; pending downloads resume automatically
- **Pause / Resume / Cancel** controls per batch
- **Retry failed tasks** individually
- **API JSON archiving** — automatically saves model and version JSON metadata to disk for future scanning

### ⚙️ Settings

- Configure model storage path, CivitAI API token, and HTTP proxy
- One-click model scanner with progress reporting

## Screenshot

```
+---+ Local Models +---+ Download +---+ Stats +---+ Settings +---+
|                                                                |
|  Browse your CivitAI models    [ Download | Stats | Settings ]  |
|                                                                |
+----------------------------------------------------------------+
```

## Prerequisites

- **Windows** (primary target; Linux and macOS should work via Flutter cross-platform)
- **CivitAI API token** (optional but recommended — enables NSFW model access)
  - Get one at [civitai.com/user/account](https://civitai.com/user/account)

## Getting Started

### Build from source

```bash
# Clone the repository
git clone <repo-url>
cd flutter_civitai_box

# Install dependencies
flutter pub get

# Run
flutter run -d windows
```

### First Launch

1. Open **Settings** — set your model storage path and CivitAI API token
2. Click **Scan Models** to discover existing local models
3. Browse models on the **Local Models** tab
4. Use the **Download** tab to fetch new models from CivitAI

## Project Structure

```
lib/
├── main.dart                  — App entry point & navigation shell
├── civitai_api/               — CivitAI REST API client (Dio-based)
│   ├── endpoints/             — /models, /model-versions endpoint handlers
│   └── models/                — Freezed data models (Model, Version, File, Image, etc.)
├── db/                        — SQLite database layer (sqflite)
│   ├── dao/                   — Per-table DAO classes
│   ├── repository/            — High-level business logic
│   └── tables.dart            — DDL & schema constants
├── services/
│   ├── download/              — Download task system (queue, persistence, execution)
│   ├── scanner/               — Local file scanner
│   ├── hash_check_service.dart— SHA256 file integrity verification
│   └── file_layout.dart       — Canonical directory layout helpers
├── ui/
│   ├── download/              — Download page (Fetch + Queue UI)
│   ├── local_models/          — Model browser, detail page, cards
│   ├── stats/                 — Statistics dashboard & integrity checker
│   └── settings/              — Settings page & first-launch wizard
└── settings/                  — SharedPreferences-based settings
```

## Database Schema

The app uses SQLite with the following tables:

| Table                 | Purpose                                              |
| --------------------- | ---------------------------------------------------- |
| `model`               | CivitAI models (id, name, type, NSFW, full API JSON) |
| `model_version`       | Model versions (base model, files, images)           |
| `model_version_file`  | Downloadable files (name, size, download URL)        |
| `model_version_image` | Preview images (URL, dimensions, perceptual hash)    |
| `creator`             | Model creators (username, avatar)                    |
| `model_type`          | Model categories (Checkpoint, LoRA, etc.)            |
| `base_model`          | Base model names (SD 1.5, SDXL, Flux, etc.)          |
| `tag`                 | Tags with many-to-many model association             |
| `download_task`       | Download queue persistence                           |

See `lib/db/SCHEMA.md` for the full schema.

## File Layout

Models are stored in a canonical directory structure:

```
{basePath}/
  Checkpoint/
    12345/
      12345.api-info.json
      67890/
        67890.api-info.json
        files/
          dreamshaper.safetensors
        media/
          1743604.jpeg
  LoRA/
    ...
```

## Tech Stack

- **Flutter** — cross-platform UI framework
- **sqflite** — SQLite database
- **Dio** — HTTP client
- **Freezed** — immutable data classes with JSON serialization
- **background_downloader** — background file downloads
- **fl_chart** — statistics charts
- **media_kit** — video preview playback
- **talker** — logging

## License

MIT
