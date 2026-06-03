# Download System Design

> Fetch CivitAI model/version data, download all files, persist to disk, and display a queue.
> Atomic unit: **ModelVersion** — one version = one batch.

---

## Core Design Principles

| Principle | Decision |
|-----------|----------|
| **Atomic unit** | Download by **ModelVersion** — one version = one batch |
| **Persistence** | `download_task` table survives app restart |
| **Concurrency** | Batched: model files first (x2), then media files (x4) |
| **Downloader** | `background_downloader` — supports background execution |
| **UI** | Merged into Download page (Fetch on top, Queue below) |
| **Post-download** | `ModelRefreshBus.notify()` — no full scanner needed |
| **File existence** | Check disk, no extra DB flag |

---

## Database

### `download_task` Table

```sql
CREATE TABLE download_task (
  id                   TEXT    PRIMARY KEY,           -- UUID
  batch_id             TEXT    NOT NULL,              -- groups tasks under one ModelVersion
  model_id             INTEGER NOT NULL,
  model_version_id     INTEGER NOT NULL,
  file_name            TEXT    NOT NULL,
  file_size_kb         REAL    NOT NULL,
  download_url         TEXT    NOT NULL,
  target_path          TEXT    NOT NULL,              -- full disk path
  file_type            TEXT    NOT NULL,              -- 'model' | 'media' | 'api_json'
  status               TEXT    NOT NULL DEFAULT 'pending',
                       -- pending | downloading | completed | failed | cancelled
  progress             REAL    NOT NULL DEFAULT 0,    -- 0.0 ~ 1.0
  error_message        TEXT,
  background_task_id   TEXT,                          -- background_downloader task ID
  created_at           TEXT    NOT NULL,
  updated_at           TEXT    NOT NULL
);

CREATE INDEX idx_download_task_batch ON download_task(batch_id);
CREATE INDEX idx_download_task_status ON download_task(status);
```

### Batch Concept

A **batch** groups all tasks for one ModelVersion (derived from `batch_id`):

| `file_type` | Files per batch | Priority | Concurrent |
|-------------|-----------------|----------|-------------|
| `api_json` | 2 (model + version) | 0 — writes instantly, no download | — |
| `model` | 1~3 (.safetensors, .ckpt) | 1 — downloads first | x2 |
| `media` | 5~20 (.jpeg, .png, .mp4) | 2 — downloads after models done | x4 |

---

## File Layout

```txt
{basePath}/
  {modelType}/                          ← e.g. Checkpoint, LoRA
    {modelId}/
      {modelId}.api-info.json           ← GET /api/v1/models/{modelId}
      {versionId}/
        {versionId}.api-info.json       ← GET /api/v1/model-versions/{versionId}
        files/
          model.safetensors             ← files[].downloadUrl
          model_fp16.safetensors
        media/
          {imageId}.jpeg                ← images[].url → extract numeric ID
          {imageId}.mp4
```

### API JSON Field Usage

| File | Source | Limits | Description |
|------|--------|--------|-------------|
| `{modelId}.api-info.json` | `GET /api/v1/models/{id}` | None | Preserve all fields (including `modelVersions`) |
| `{versionId}.api-info.json` | `GET /api/v1/model-versions/{id}` | None | Preserve all fields |

> Model-level JSON retains `modelVersions`. Write amplification on QLC SSD is negligible.

---

## Architecture

```txt
lib/
├── services/
│   └── download/
│       ├── download_task.dart          — Data models (DownloadTask, DownloadBatch, status enum)
│       ├── download_database.dart      — CRUD for download_task table
│       └── download_queue.dart         — Queue engine (enqueue, execute, pause, resume, restore on startup)
└── ui/
    └── download/
        ├── download_page.dart          — Merged page (Fetch section + Queue section)
        └── widgets/
            ├── download_batch_card.dart — One ModelVersion batch with expandable file list
            └── download_task_tile.dart  — Single file progress bar + status icon
```

---

## Data Flow

```mermaid
sequenceDiagram
    participant U as User
    participant DP as DownloadPage
    participant API as CivitAI API
    participant Q as DownloadQueue
    participant BDL as background_downloader
    participant Disk as File System
    participant Bus as ModelRefreshBus

    U->>DP: Select versions → "Download"
    DP->>API: GET model/{id} + GET model-versions/{id}
    API-->>DP: Model JSON + Version JSON
    DP->>Disk: Write {modelId}.api-info.json (retain all fields)
    DP->>Disk: Write {versionId}.api-info.json
    DP->>Q: enqueue(batch)
    Q->>Q: Persist all tasks to download_task table
    Q-->>DP: Stream progress updates

    loop Model files (x2 concurrent)
        Q->>BDL: download(url, targetPath)
        BDL-->>Q: progress / complete
        Q->>Q: Update download_task row
    end

    loop Media files (x4 concurrent)
        Q->>BDL: download(url, targetPath)
        BDL-->>Q: progress / complete
    end

    Q->>Bus: notify()
    Bus-->>DP: Refresh UI
```

---

## Queue Lifecycle

```txt
                    +----------+
          enqueue → | pending  |
                    +----+-----+
                         | start()
                    +----v-----+
          +---------+ running  +---------+
          | pause() +----+-----+ cancel()|
     +----v---+          |          +----v------+
     | paused |    resume()         | cancelled |
     +--------+          |          +-----------+
                    +----v-----+
                    |completed |
                    +----------+
```

---

## Implementation Notes

### Media file size

CivitAI image objects lack `sizeKB`. `DownloadTask.fileSizeKb` is `0` for media; `sizeFormatted` returns `—`.

### background_downloader naming conflict

Package exports its own `DownloadTask`. Resolved with `import '...' as bg;`.

### Startup restore

`DownloadQueue.instance.init()` called in `main()` after sqflite init. Restores `pending`/`downloading`/`failed` tasks.

### Model-level JSON

Retains all fields including `modelVersions`. Write amplification on QLC SSD is negligible.

---

## Edge Cases

| Case | Handling |
|------|----------|
| Invalid ID (NaN) | Validation error message |
| API 404 | "Not found" — check API key if NSFW |
| Network error mid-download | Mark task `failed`, continue remaining tasks in batch |
| App killed mid-download | On restart: query `status IN ('pending','downloading')`, resume |
| File already exists on disk | Skip download, mark `completed` immediately |
| `background_downloader` task ID lost | Re-enqueue as new download |
| Duplicate enqueue (same version already in queue) | Check existing batch, offer overwrite or skip |
| Media URL has no numeric ID | Skip that image with warning log |
