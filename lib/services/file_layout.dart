import 'package:path/path.dart' as p;

/// Canonical directory layout for locally stored CivitAI models.
///
/// ```
/// {basePath}/
///   {modelType}/
///     {modelId}/
///       {modelId}.api-info.json
///       {versionId}/
///         {versionId}.api-info.json
///         files/
///           {fileName}.safetensors
///         media/
///           {imageId}.jpeg
/// ```
///
/// Mirrors the structure defined in the bun-civitai-browser `file-layout.ts`.

/// `{basePath}/{modelType}/{modelId}`
String getModelIdPath(String basePath, String modelType, int modelId) =>
    p.join(p.normalize(basePath), modelType, modelId.toString());

/// `{basePath}/{modelType}/{modelId}/{versionId}`
String getModelVersionPath(
  String basePath,
  String modelType,
  int modelId,
  int versionId,
) => p.join(getModelIdPath(basePath, modelType, modelId), versionId.toString());

/// `{basePath}/{modelType}/{modelId}/{versionId}/files`
String getFilesDir(
  String basePath,
  String modelType,
  int modelId,
  int versionId,
) => p.join(
  getModelVersionPath(basePath, modelType, modelId, versionId),
  'files',
);

/// `{basePath}/{modelType}/{modelId}/{versionId}/media`
String getMediaDir(
  String basePath,
  String modelType,
  int modelId,
  int versionId,
) => p.join(
  getModelVersionPath(basePath, modelType, modelId, versionId),
  'media',
);

/// `{id}.api-info.json`
String getApiInfoJsonFileName(int id) => '$id.api-info.json';

/// `{basePath}/{modelType}/{modelId}/{modelId}.api-info.json`
String getModelIdApiInfoJsonPath(
  String basePath,
  String modelType,
  int modelId,
) => p.join(
  getModelIdPath(basePath, modelType, modelId),
  getApiInfoJsonFileName(modelId),
);

/// `{basePath}/{modelType}/{modelId}/{versionId}/{versionId}.api-info.json`
String getModelVersionApiInfoJsonPath(
  String basePath,
  String modelType,
  int modelId,
  int versionId,
) => p.join(
  getModelVersionPath(basePath, modelType, modelId, versionId),
  getApiInfoJsonFileName(versionId),
);

// ---------------------------------------------------------------------------
// User-custom file paths (survives model deletion)
// ---------------------------------------------------------------------------

/// `{basePath}/user_custom/previews`
String getUserCustomPreviewsDir(String basePath) =>
    p.join(p.normalize(basePath), 'user_custom', 'previews');

/// `{basePath}/user_custom/previews/{modelId}_{versionId}.{formatSuffix}`
String getUserCustomPreviewPath(
  String basePath,
  int modelId,
  int versionId,
  String formatSuffix,
) => p.join(
  getUserCustomPreviewsDir(basePath),
  '${modelId}_$versionId.$formatSuffix',
);

// ---------------------------------------------------------------------------
// Markdown note file paths
// ---------------------------------------------------------------------------

/// `{basePath}/user_custom/markdown_notes`
String getUserCustomMarkdownNotesDir(String basePath) =>
    p.join(p.normalize(basePath), 'user_custom', 'markdown_notes');

/// `{basePath}/user_custom/markdown_notes/{modelId}.md` — model-level note
String getUserCustomModelNotePath(String basePath, int modelId) =>
    p.join(getUserCustomMarkdownNotesDir(basePath), '$modelId.md');

/// `{basePath}/user_custom/markdown_notes/{modelId}_{versionId}.md` — version-level note
String getUserCustomVersionNotePath(
  String basePath,
  int modelId,
  int versionId,
) =>
    p.join(getUserCustomMarkdownNotesDir(basePath), '${modelId}_$versionId.md');

/// `{basePath}/{modelType}/{modelId}/{versionId}/{versionId}.api-info.json`
