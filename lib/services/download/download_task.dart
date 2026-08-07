/// Types of files in a download batch.
enum DownloadFileType { model, media, apiJson }

/// Status of a single download task or batch.
enum DownloadTaskStatus { pending, downloading, completed, failed, cancelled }

/// Status helpers on String.
extension DownloadTaskStatusExt on String {
  DownloadTaskStatus get asStatus {
    switch (this) {
      case 'pending':
        return DownloadTaskStatus.pending;
      case 'downloading':
        return DownloadTaskStatus.downloading;
      case 'completed':
        return DownloadTaskStatus.completed;
      case 'failed':
        return DownloadTaskStatus.failed;
      case 'cancelled':
        return DownloadTaskStatus.cancelled;
      default:
        return DownloadTaskStatus.pending;
    }
  }
}

/// A single file download task, persisted to `download_task` table.
class DownloadTask {
  final String id;
  final String batchId;
  final int modelId;
  final int modelVersionId;
  final String? modelName;
  final String? versionName;
  final String fileName;
  final double fileSizeKb;
  final String downloadUrl;
  final String targetPath;
  final DownloadFileType fileType;
  DownloadTaskStatus status;
  double progress;
  String? errorMessage;
  String? backgroundTaskId;
  final String createdAt;
  String updatedAt;

  DownloadTask({
    required this.id,
    required this.batchId,
    required this.modelId,
    required this.modelVersionId,
    this.modelName,
    this.versionName,
    required this.fileName,
    required this.fileSizeKb,
    required this.downloadUrl,
    required this.targetPath,
    required this.fileType,
    this.status = DownloadTaskStatus.pending,
    this.progress = 0,
    this.errorMessage,
    this.backgroundTaskId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DownloadTask.fromRow(Map<String, dynamic> row) {
    return DownloadTask(
      id: row['id'] as String,
      batchId: row['batch_id'] as String,
      modelId: row['model_id'] as int,
      modelVersionId: row['model_version_id'] as int,
      modelName: row['model_name'] as String?,
      versionName: row['version_name'] as String?,
      fileName: row['file_name'] as String,
      fileSizeKb: (row['file_size_kb'] as num).toDouble(),
      downloadUrl: row['download_url'] as String,
      targetPath: row['target_path'] as String,
      fileType: _parseFileType(row['file_type'] as String),
      status: (row['status'] as String).asStatus,
      progress: (row['progress'] as num).toDouble(),
      errorMessage: row['error_message'] as String?,
      backgroundTaskId: row['background_task_id'] as String?,
      createdAt: row['created_at'] as String,
      updatedAt: row['updated_at'] as String,
    );
  }

  Map<String, dynamic> toRow() => {
    'id': id,
    'batch_id': batchId,
    'model_id': modelId,
    'model_version_id': modelVersionId,
    'model_name': modelName,
    'version_name': versionName,
    'file_name': fileName,
    'file_size_kb': fileSizeKb,
    'download_url': downloadUrl,
    'target_path': targetPath,
    'file_type': fileType.name,
    'status': status.name,
    'progress': progress,
    'error_message': errorMessage,
    'background_task_id': backgroundTaskId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  String get sizeFormatted {
    if (fileSizeKb <= 0) return '—';
    if (fileSizeKb >= 1024 * 1024) {
      return '${(fileSizeKb / (1024 * 1024)).toStringAsFixed(1)} GB';
    }
    if (fileSizeKb >= 1024) {
      return '${(fileSizeKb / 1024).toStringAsFixed(0)} MB';
    }
    return '${fileSizeKb.toStringAsFixed(0)} KB';
  }

  static DownloadFileType _parseFileType(String s) {
    switch (s) {
      case 'model':
        return DownloadFileType.model;
      case 'media':
        return DownloadFileType.media;
      case 'apiJson':
        return DownloadFileType.apiJson;
      default:
        return DownloadFileType.model;
    }
  }
}

/// Aggregated state of all download tasks, streamed to UI.
class DownloadQueueState {
  final List<DownloadTask> tasks;
  final int totalBatches;
  final int completedBatches;

  const DownloadQueueState({
    required this.tasks,
    required this.totalBatches,
    required this.completedBatches,
  });

  /// Tasks grouped by batch_id.
  Map<String, List<DownloadTask>> get batches {
    final map = <String, List<DownloadTask>>{};
    for (final t in tasks) {
      map.putIfAbsent(t.batchId, () => []).add(t);
    }
    return map;
  }

  /// Only active batches (not all completed).
  List<MapEntry<String, List<DownloadTask>>> get activeBatches {
    return batches.entries
        .where(
          (e) => e.value.any(
            (t) =>
                t.status == DownloadTaskStatus.pending ||
                t.status == DownloadTaskStatus.downloading ||
                t.status == DownloadTaskStatus.failed,
          ),
        )
        .toList();
  }

  /// Completed batches (history).
  List<MapEntry<String, List<DownloadTask>>> get completedBatchList {
    return batches.entries
        .where(
          (e) => e.value.every((t) => t.status == DownloadTaskStatus.completed),
        )
        .toList();
  }
}
