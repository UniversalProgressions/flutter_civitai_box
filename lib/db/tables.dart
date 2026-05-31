/// SQL table creation statements mirroring the Prisma schema from the
/// bun-civitai-browser project.
///
/// All `@id` fields are mapped to INTEGER PRIMARY KEY.
/// `@unique` → UNIQUE constraint.
/// `@default(now())` / `@updatedAt` → handled in Dart insert/update logic.
/// `Json` columns → TEXT (stored as JSON string).
/// `Boolean` → INTEGER (0/1) per SQLite convention.
library;

/// ---------------------------------------------------------------------------
/// Creator
/// ---------------------------------------------------------------------------
const String createCreatorTable = '''
CREATE TABLE IF NOT EXISTS creator (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  username  TEXT    NOT NULL UNIQUE,
  link      TEXT,
  image     TEXT
);
CREATE INDEX IF NOT EXISTS idx_creator_username ON creator(username);
''';

/// ---------------------------------------------------------------------------
/// ModelType
/// ---------------------------------------------------------------------------
const String createModelTypeTable = '''
CREATE TABLE IF NOT EXISTS model_type (
  id   INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT    NOT NULL UNIQUE
);
CREATE INDEX IF NOT EXISTS idx_model_type_name ON model_type(name);
''';

/// ---------------------------------------------------------------------------
/// Tag
/// ---------------------------------------------------------------------------
const String createTagTable = '''
CREATE TABLE IF NOT EXISTS tag (
  id   INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT    NOT NULL UNIQUE
);
CREATE INDEX IF NOT EXISTS idx_tag_name ON tag(name);
''';

/// ---------------------------------------------------------------------------
/// BaseModel
/// ---------------------------------------------------------------------------
const String createBaseModelTable = '''
CREATE TABLE IF NOT EXISTS base_model (
  id   INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT    NOT NULL UNIQUE
);
CREATE INDEX IF NOT EXISTS idx_base_model_name ON base_model(name);
''';

/// ---------------------------------------------------------------------------
/// BaseModelType
/// ---------------------------------------------------------------------------
const String createBaseModelTypeTable = '''
CREATE TABLE IF NOT EXISTS base_model_type (
  id           INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name         TEXT    NOT NULL UNIQUE,
  base_model_id INTEGER NOT NULL,
  FOREIGN KEY (base_model_id) REFERENCES base_model(id)
);
CREATE INDEX IF NOT EXISTS idx_base_model_type_name
  ON base_model_type(name, base_model_id);
''';

/// ---------------------------------------------------------------------------
/// Model
/// ---------------------------------------------------------------------------
const String createModelTable = '''
CREATE TABLE IF NOT EXISTS model (
  id            INTEGER NOT NULL PRIMARY KEY,
  name          TEXT    NOT NULL,
  creator_id    INTEGER,
  type_id       INTEGER NOT NULL,
  nsfw          INTEGER NOT NULL DEFAULT 0,
  nsfw_level    INTEGER NOT NULL,
  json          TEXT    NOT NULL DEFAULT '{}',
  created_at    TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at    TEXT    NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (creator_id) REFERENCES creator(id),
  FOREIGN KEY (type_id)    REFERENCES model_type(id)
);
CREATE INDEX IF NOT EXISTS idx_model_lookup
  ON model(name, type_id, creator_id, nsfw, nsfw_level);
''';

/// ---------------------------------------------------------------------------
/// Model ↔ Tag  (junction / many-to-many)
/// ---------------------------------------------------------------------------
const String createModelTagsTable = '''
CREATE TABLE IF NOT EXISTS model_tags (
  model_id INTEGER NOT NULL,
  tag_id   INTEGER NOT NULL,
  PRIMARY KEY (model_id, tag_id),
  FOREIGN KEY (model_id) REFERENCES model(id) ON DELETE CASCADE,
  FOREIGN KEY (tag_id)   REFERENCES tag(id)   ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_model_tags_tag ON model_tags(tag_id);
''';

/// ---------------------------------------------------------------------------
/// ModelVersion
/// ---------------------------------------------------------------------------
const String createModelVersionTable = '''
CREATE TABLE IF NOT EXISTS model_version (
  id                INTEGER NOT NULL PRIMARY KEY,
  model_id          INTEGER NOT NULL,
  name              TEXT    NOT NULL,
  base_model_id     INTEGER NOT NULL,
  base_model_type_id INTEGER,
  nsfw_level        INTEGER NOT NULL,
  json              TEXT    NOT NULL DEFAULT '{}',
  created_at        TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at        TEXT    NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (model_id)          REFERENCES model(id)          ON DELETE CASCADE,
  FOREIGN KEY (base_model_id)     REFERENCES base_model(id),
  FOREIGN KEY (base_model_type_id) REFERENCES base_model_type(id)
);
CREATE INDEX IF NOT EXISTS idx_model_version_lookup
  ON model_version(model_id, name, base_model_id, base_model_type_id, nsfw_level);
''';

/// ---------------------------------------------------------------------------
/// ModelVersionFile
/// ---------------------------------------------------------------------------
const String createModelVersionFileTable = '''
CREATE TABLE IF NOT EXISTS model_version_file (
  id                   INTEGER NOT NULL PRIMARY KEY,
  size_kb              REAL    NOT NULL,
  name                 TEXT    NOT NULL,
  type                 TEXT    NOT NULL,
  download_url         TEXT    NOT NULL,
  model_version_id     INTEGER NOT NULL,
  FOREIGN KEY (model_version_id) REFERENCES model_version(id) ON DELETE CASCADE
);
''';

/// ---------------------------------------------------------------------------
/// ModelVersionImage
/// ---------------------------------------------------------------------------
const String createModelVersionImageTable = '''
CREATE TABLE IF NOT EXISTS model_version_image (
  id                   INTEGER NOT NULL PRIMARY KEY,
  url                  TEXT    NOT NULL,
  nsfw_level           INTEGER NOT NULL,
  width                INTEGER NOT NULL,
  height               INTEGER NOT NULL,
  hash                 TEXT    NOT NULL,
  type                 TEXT    NOT NULL,
  model_version_id     INTEGER NOT NULL,
  FOREIGN KEY (model_version_id) REFERENCES model_version(id) ON DELETE CASCADE
);
''';

/// ---------------------------------------------------------------------------
/// UserCustomPreview
/// ---------------------------------------------------------------------------
const String createUserCustomPreviewTable = '''
CREATE TABLE IF NOT EXISTS user_custom_preview (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  model_id         INTEGER NOT NULL,
  model_version_id INTEGER NOT NULL UNIQUE,
  file_hash        TEXT    NOT NULL,
  file_name        TEXT    NOT NULL,
  format_suffix    TEXT    NOT NULL,
  created_at       TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at       TEXT    NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_user_custom_preview_model
  ON user_custom_preview(model_id);
CREATE INDEX IF NOT EXISTS idx_user_custom_preview_version
  ON user_custom_preview(model_version_id);
''';

/// ---------------------------------------------------------------------------
/// UserCustomTag
/// ---------------------------------------------------------------------------
const String createUserCustomTagTable = '''
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
''';

/// ---------------------------------------------------------------------------
/// SavedSearch
/// ---------------------------------------------------------------------------
const String createSavedSearchTable = '''
CREATE TABLE IF NOT EXISTS saved_search (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  name       TEXT    NOT NULL UNIQUE,
  json       TEXT    NOT NULL DEFAULT '{}',
  created_at TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT    NOT NULL DEFAULT (datetime('now'))
);
''';

/// Ordered list of all CREATE statements for the migration runner.
const List<String> allCreateStatements = [
  createCreatorTable,
  createModelTypeTable,
  createTagTable,
  createBaseModelTable,
  createBaseModelTypeTable,
  createModelTable,
  createModelTagsTable,
  createModelVersionTable,
  createModelVersionFileTable,
  createModelVersionImageTable,
  createUserCustomPreviewTable,
  createUserCustomTagTable,
  createSavedSearchTable,
];
