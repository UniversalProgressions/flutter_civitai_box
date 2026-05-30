/// Types emitted by the model scanner.
library;

sealed class ScanEvent {
  const ScanEvent();
}

/// Progress snapshot emitted after each file is processed.
final class ScanProgress extends ScanEvent {
  final int filesFound;
  final int filesProcessed;
  final int upserted;
  final int skipped;
  final int errors;
  final String? currentFile;
  final String? lastError;

  const ScanProgress({
    required this.filesFound,
    required this.filesProcessed,
    required this.upserted,
    required this.skipped,
    required this.errors,
    this.currentFile,
    this.lastError,
  });

  double get fraction => filesFound == 0 ? 0 : filesProcessed / filesFound;
}

/// Final result returned when the scan completes.
final class ScanResult extends ScanEvent {
  final int filesFound;
  final int upserted;
  final int skipped;
  final int errors;
  final List<String> errorDetails;
  final Duration duration;

  const ScanResult({
    required this.filesFound,
    required this.upserted,
    required this.skipped,
    required this.errors,
    required this.errorDetails,
    required this.duration,
  });
}

/// Info parsed from a model file path.
final class ModelFileInfo {
  final String modelType;
  final int modelId;
  final int versionId;
  final String filePath;
  final String fileName;
  final String fileExtension;
  final bool isNewLayout;

  const ModelFileInfo({
    required this.modelType,
    required this.modelId,
    required this.versionId,
    required this.filePath,
    required this.fileName,
    required this.fileExtension,
    required this.isNewLayout,
  });
}
