import 'package:dio/dio.dart';

import 'civitai_api_exception.dart';
import 'models/model.dart';
import 'models/model_id.dart';
import 'models/shared.dart';

/// Converts a [ModelById] (from GET /models/:id) into a [Model]
/// (the format used in list/search responses).
Model modelId2Model(ModelById data) {
  final versions = data.modelVersions.map((mv) {
    final images = mv.images.map((img) {
      final id = extractIdFromImageUrl(img.url) ?? 0;
      return ModelImageWithId(
        id: id,
        url: img.url,
        nsfwLevel: img.nsfwLevel,
        width: img.width,
        height: img.height,
        hash: img.hash,
        type: img.type,
      );
    }).toList();

    final files = mv.files
        .map((f) => f.copyWith(scannedAt: f.scannedAt?.toUtc()))
        .toList();

    return ModelVersion(
      id: mv.id,
      index: mv.index,
      name: mv.name,
      baseModel: mv.baseModel,
      baseModelType: mv.baseModelType,
      publishedAt: mv.publishedAt?.toUtc(),
      availability: mv.availability,
      nsfwLevel: mv.nsfwLevel,
      description: mv.description,
      trainedWords: mv.trainedWords,
      stats: mv.stats,
      files: files,
      images: images,
    );
  }).toList();

  return Model(
    id: data.id,
    name: data.name,
    description: data.description,
    type: data.type,
    poi: data.poi,
    nsfw: data.nsfw,
    nsfwLevel: data.nsfwLevel,
    creator: data.creator,
    stats: data.stats,
    tags: data.tags,
    modelVersions: versions,
  );
}

/// Extracts the filename (last path segment) from a URL.
/// Returns `null` if the URL is invalid or has no filename.
String? extractFilenameFromUrl(String url) {
  try {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments
        .where((s) => s.trim().isNotEmpty)
        .toList();
    if (segments.isEmpty) return null;
    final filename = segments.last.split(RegExp(r'[?#]')).first;
    return filename.isEmpty ? null : filename;
  } catch (_) {
    return null;
  }
}

/// Removes the file extension from a filename.
String removeFileExtension(String filename) {
  final lastDot = filename.lastIndexOf('.');
  final lastSep = [
    filename.lastIndexOf('/'),
    filename.lastIndexOf('\\'),
  ].reduce((a, b) => a > b ? a : b);
  if (lastDot == -1 || lastDot < lastSep) return filename;
  return filename.substring(0, lastDot);
}

/// Extracts a numeric ID from a CivitAI image URL.
/// Returns `null` if parsing fails.
///
/// Example: `https://image.civitai.com/.../width=1024/1743606.jpeg` → `1743606`.
int? extractIdFromImageUrl(String url) {
  final filename = extractFilenameFromUrl(url);
  if (filename == null) return null;
  final withoutExt = removeFileExtension(filename);
  return int.tryParse(withoutExt);
}

/// Determines file type from a filename extension.
String getFileType(String filename) {
  if (filename.isEmpty) return 'unknown';
  final ext = filename.split('.').last.toLowerCase();

  const imageExts = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg', 'avif'];
  const videoExts = ['mp4', 'webm', 'ogg', 'mov', 'avi', 'mkv', 'flv'];

  if (imageExts.contains(ext)) return 'image';
  if (videoExts.contains(ext)) return 'video';
  return 'unknown';
}

/// Converts a Dart map to query parameters for HTTP requests.
///
/// Handles list values by joining them with commas (CivitAI API format).
Map<String, dynamic> obj2QueryParams(Map<String, dynamic> params) {
  final result = <String, dynamic>{};
  for (final entry in params.entries) {
    if (entry.value == null) continue;
    if (entry.value is List) {
      result[entry.key] = (entry.value as List)
          .map((e) => e.toString())
          .join(',');
    } else {
      result[entry.key] = entry.value.toString();
    }
  }
  return result;
}

/// Maps a [DioException] to a [CivitaiApiException] or [CivitaiNetworkException].
Exception mapDioError(DioException e) {
  final msg = e.message ?? 'Unknown error';

  switch (e.type) {
    case DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout:
      return CivitaiNetworkException('Request timed out: $msg', e);
    case DioExceptionType.connectionError:
      return CivitaiNetworkException('Connection failed: $msg', e);
    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode ?? 0;
      final data = e.response?.data;
      String message = e.message ?? 'Unknown API error';
      if (data is Map<String, dynamic>) {
        message = (data['error'] ?? data['message'] ?? message).toString();
      } else if (data is String) {
        message = data;
      }
      return CivitaiApiException(statusCode, message);
    default:
      return CivitaiNetworkException(msg, e);
  }
}
