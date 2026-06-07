/// Status of a round in the download magazine.
enum MagazineItemStatus { pending, firing, failed, skipped }

/// Extension for parsing [MagazineItemStatus] from database strings.
extension MagazineItemStatusX on MagazineItemStatus {
  /// Parse a status string from the database into a [MagazineItemStatus].
  static MagazineItemStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return MagazineItemStatus.pending;
      case 'firing':
        return MagazineItemStatus.firing;
      case 'failed':
        return MagazineItemStatus.failed;
      case 'skipped':
        return MagazineItemStatus.skipped;
      default:
        throw ArgumentError('Unknown MagazineItemStatus: $value');
    }
  }
}

/// A single round in the download magazine — one model version to download.
///
/// Holds parsed display fields for the UI plus the full API JSON responses
/// for use during the Fire phase.
class MagazineItem {
  final int id;
  final int modelVersionId;
  final int modelId;
  final String modelName;
  final String? versionName;
  final String? baseModel;
  final String? modelType;
  final int fileCount;
  final double totalSizeKb;
  final String modelJson;
  final String versionJson;
  final MagazineItemStatus status;
  final int retryCount;
  final String? errorMessage;
  final DateTime loadedAt;
  final DateTime? firedAt;

  const MagazineItem({
    required this.id,
    required this.modelVersionId,
    required this.modelId,
    required this.modelName,
    this.versionName,
    this.baseModel,
    this.modelType,
    this.fileCount = 0,
    this.totalSizeKb = 0,
    required this.modelJson,
    required this.versionJson,
    required this.status,
    this.retryCount = 0,
    this.errorMessage,
    required this.loadedAt,
    this.firedAt,
  });

  @override
  bool operator ==(Object other) =>
      other is MagazineItem &&
      other.id == id &&
      other.modelVersionId == modelVersionId &&
      other.modelId == modelId &&
      other.modelName == modelName &&
      other.versionName == versionName &&
      other.baseModel == baseModel &&
      other.modelType == modelType &&
      other.fileCount == fileCount &&
      other.totalSizeKb == totalSizeKb &&
      other.modelJson == modelJson &&
      other.versionJson == versionJson &&
      other.status == status &&
      other.retryCount == retryCount &&
      other.errorMessage == errorMessage &&
      other.loadedAt == loadedAt &&
      other.firedAt == firedAt;

  @override
  int get hashCode => Object.hash(
    id,
    modelVersionId,
    modelId,
    modelName,
    versionName,
    baseModel,
    modelType,
    fileCount,
    totalSizeKb,
    modelJson,
    versionJson,
    status,
    retryCount,
    errorMessage,
    loadedAt,
    firedAt,
  );

  /// Create a [MagazineItem] from a SQLite row map.
  factory MagazineItem.fromRow(Map<String, Object?> row) {
    final id = row['id'];
    final modelVersionId = row['model_version_id'];
    final modelId = row['model_id'];
    final modelName = row['model_name'];
    if (id == null) throw ArgumentError('Missing required field: id');
    if (modelVersionId == null) {
      throw ArgumentError('Missing required field: model_version_id');
    }
    if (modelId == null) {
      throw ArgumentError('Missing required field: model_id');
    }
    if (modelName == null) {
      throw ArgumentError('Missing required field: model_name');
    }
    return MagazineItem(
      id: row['id'] as int,
      modelVersionId: row['model_version_id'] as int,
      modelId: row['model_id'] as int,
      modelName: row['model_name'] as String,
      versionName: row['version_name'] as String?,
      baseModel: row['base_model'] as String?,
      modelType: row['model_type'] as String?,
      fileCount: row['file_count'] as int,
      totalSizeKb: _toDouble(row['total_size_kb']),
      modelJson: row['model_json'] as String,
      versionJson: row['version_json'] as String,
      status: MagazineItemStatusX.fromString(row['status'] as String),
      retryCount: row['retry_count'] as int,
      errorMessage: row['error_message'] as String?,
      loadedAt: DateTime.parse(row['loaded_at'] as String),
      firedAt: row['fired_at'] != null
          ? DateTime.parse(row['fired_at'] as String)
          : null,
    );
  }

  /// Convert this [MagazineItem] to a SQLite row map.
  Map<String, Object?> toRow() {
    return {
      'id': id,
      'model_version_id': modelVersionId,
      'model_id': modelId,
      'model_name': modelName,
      'version_name': versionName,
      'base_model': baseModel,
      'model_type': modelType,
      'file_count': fileCount,
      'total_size_kb': totalSizeKb,
      'model_json': modelJson,
      'version_json': versionJson,
      'status': status.name,
      'retry_count': retryCount,
      'error_message': errorMessage,
      'loaded_at': loadedAt.toIso8601String(),
      'fired_at': firedAt?.toIso8601String(),
    };
  }

  /// Create a copy with optional field overrides.
  ///
  /// For nullable fields ([versionName], [baseModel], [modelType],
  /// [errorMessage], [firedAt]), passing `null` explicitly sets the field
  /// to null. Omit the parameter to keep the existing value.
  MagazineItem copyWith({
    int? id,
    int? modelVersionId,
    int? modelId,
    String? modelName,
    String? versionName,
    String? baseModel,
    String? modelType,
    int? fileCount,
    double? totalSizeKb,
    String? modelJson,
    String? versionJson,
    MagazineItemStatus? status,
    int? retryCount,
    String? errorMessage,
    DateTime? loadedAt,
    DateTime? firedAt,
    bool clearErrorMessage = false,
    bool clearFiredAt = false,
  }) {
    return MagazineItem(
      id: id ?? this.id,
      modelVersionId: modelVersionId ?? this.modelVersionId,
      modelId: modelId ?? this.modelId,
      modelName: modelName ?? this.modelName,
      versionName: versionName ?? this.versionName,
      baseModel: baseModel ?? this.baseModel,
      modelType: modelType ?? this.modelType,
      fileCount: fileCount ?? this.fileCount,
      totalSizeKb: totalSizeKb ?? this.totalSizeKb,
      modelJson: modelJson ?? this.modelJson,
      versionJson: versionJson ?? this.versionJson,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      loadedAt: loadedAt ?? this.loadedAt,
      firedAt: clearFiredAt ? null : (firedAt ?? this.firedAt),
    );
  }

  @override
  String toString() =>
      'MagazineItem(id: $id, modelVersionId: $modelVersionId, '
      'modelName: $modelName, status: $status)';
}

/// Convert a value that could be int or double to double.
double _toDouble(Object? value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value == null) return 0.0;
  return (value as num).toDouble();
}

// =============================================================================
// LoadResult
// =============================================================================

/// Categories of errors that can occur during [load].
enum LoadErrorType {
  /// The version ID is not a positive integer.
  invalidId,

  /// Network-level error (connection refused, timeout, etc.).
  networkError,

  /// API returned a non-200 HTTP status.
  apiError,

  /// API response was missing required fields.
  validationError,

  /// The version ID is already present in the magazine.
  alreadyInMagazine,
}

/// Structured error details for a failed [load] operation.
class LoadError {
  final LoadErrorType type;
  final String message;
  final String? detail;

  const LoadError({required this.type, required this.message, this.detail});

  @override
  bool operator ==(Object other) =>
      other is LoadError &&
      other.type == type &&
      other.message == message &&
      other.detail == detail;

  @override
  int get hashCode => Object.hash(type, message, detail);

  @override
  String toString() => 'LoadError(type: $type, message: $message)';
}

/// Result of loading a round into the magazine.
sealed class LoadResult {
  /// Successfully loaded and persisted.
  const factory LoadResult.ok(MagazineItem item) = LoadOk;

  /// Validation or API error with structured details.
  const factory LoadResult.error(LoadError error) = LoadError_;

  const LoadResult._();
}

/// Successful load result.
final class LoadOk extends LoadResult {
  final MagazineItem item;
  const LoadOk(this.item) : super._();

  @override
  bool operator ==(Object other) => other is LoadOk && other.item == item;

  @override
  int get hashCode => item.hashCode;
}

/// Failed load result.
final class LoadError_ extends LoadResult {
  final LoadError error;
  const LoadError_(this.error) : super._();

  @override
  bool operator ==(Object other) => other is LoadError_ && other.error == error;

  @override
  int get hashCode => error.hashCode;
}

// =============================================================================
// FireEvent
// =============================================================================

/// Summary of a completed Fire operation.
class FireSummary {
  final int completed;
  final int skipped;
  final int failed;

  const FireSummary({
    required this.completed,
    required this.skipped,
    required this.failed,
  });

  @override
  bool operator ==(Object other) =>
      other is FireSummary &&
      other.completed == completed &&
      other.skipped == skipped &&
      other.failed == failed;

  @override
  int get hashCode => Object.hash(completed, skipped, failed);

  @override
  String toString() =>
      'FireSummary(completed: $completed, skipped: $skipped, failed: $failed)';
}

/// Events emitted during the Fire process.
sealed class FireEvent {
  /// A round has started processing.
  const factory FireEvent.roundStarted(MagazineItem item) = FireRoundStarted;

  /// Retrying a failed round (attempt 2 or 3).
  const factory FireEvent.retrying(
    MagazineItem item,
    int attempt,
    String reason,
  ) = FireRetrying;

  /// A round downloaded successfully and was removed from the magazine.
  const factory FireEvent.roundCompleted(int modelVersionId, String modelName) =
      FireRoundCompleted;

  /// A round was skipped by user unjam action.
  const factory FireEvent.roundSkipped(MagazineItem item) = FireRoundSkipped;

  /// Fire is complete — all pending rounds processed or magazine is empty.
  const factory FireEvent.done(FireSummary summary) = FireDone;

  /// MAGAZINE JAMMED — a round failed 3 times. User must intervene.
  const factory FireEvent.jammed(MagazineItem failedItem) = FireJammed;

  const FireEvent._();
}

final class FireRoundStarted extends FireEvent {
  final MagazineItem item;
  const FireRoundStarted(this.item) : super._();

  @override
  bool operator ==(Object other) =>
      other is FireRoundStarted && other.item == item;

  @override
  int get hashCode => item.hashCode;
}

final class FireRetrying extends FireEvent {
  final MagazineItem item;
  final int attempt;
  final String reason;
  const FireRetrying(this.item, this.attempt, this.reason) : super._();

  @override
  bool operator ==(Object other) =>
      other is FireRetrying &&
      other.item == item &&
      other.attempt == attempt &&
      other.reason == reason;

  @override
  int get hashCode => Object.hash(item, attempt, reason);
}

final class FireRoundCompleted extends FireEvent {
  final int modelVersionId;
  final String modelName;
  const FireRoundCompleted(this.modelVersionId, this.modelName) : super._();

  @override
  bool operator ==(Object other) =>
      other is FireRoundCompleted &&
      other.modelVersionId == modelVersionId &&
      other.modelName == modelName;

  @override
  int get hashCode => Object.hash(modelVersionId, modelName);
}

final class FireRoundSkipped extends FireEvent {
  final MagazineItem item;
  const FireRoundSkipped(this.item) : super._();

  @override
  bool operator ==(Object other) =>
      other is FireRoundSkipped && other.item == item;

  @override
  int get hashCode => item.hashCode;
}

final class FireDone extends FireEvent {
  final FireSummary summary;
  const FireDone(this.summary) : super._();

  @override
  bool operator ==(Object other) =>
      other is FireDone && other.summary == summary;

  @override
  int get hashCode => summary.hashCode;
}

final class FireJammed extends FireEvent {
  final MagazineItem failedItem;
  const FireJammed(this.failedItem) : super._();

  @override
  bool operator ==(Object other) =>
      other is FireJammed && other.failedItem == failedItem;

  @override
  int get hashCode => failedItem.hashCode;
}
