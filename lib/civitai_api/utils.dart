import 'package:dartz/dartz.dart';

import 'models/model.dart';
import 'models/model_id.dart';
import 'models/shared.dart';

/// Converts a [ModelById] (from GET /models/:id) into a [Model]
/// (the format used in list/search responses).
///
/// This is a pure transformation — no side effects.
/// Returns [Left] with an error message if conversion fails.
Either<String, Model> modelId2Model(ModelById data) {
  try {
    final versions = data.modelVersions.map((mv) {
      // Convert ModelByIdVersion → ModelVersion (add id field to images)
      final images = mv.images.map((img) {
        final idResult = extractIdFromImageUrl(img.url);
        return ModelImageWithId(
          id: idResult.fold((_) => 0, (id) => id),
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

    return right(
      Model(
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
      ),
    );
  } catch (e) {
    return left('Failed to convert ModelById to Model: $e');
  }
}

/// Extracts the filename (last path segment) from a URL.
Either<String, String> extractFilenameFromUrl(String url) {
  try {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments
        .where((s) => s.trim().isNotEmpty)
        .toList();
    if (segments.isEmpty) {
      return left('URL path is empty: $url');
    }
    final filename = segments.last.split(RegExp(r'[?#]')).first;
    if (filename.isEmpty) {
      return left('Filename is empty after removing query params: $url');
    }
    return right(filename);
  } catch (e) {
    return left('Invalid URL: $url');
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
///
/// Example: `https://image.civitai.com/.../width=1024/1743606.jpeg` → `1743606`.
Either<String, int> extractIdFromImageUrl(String url) {
  return extractFilenameFromUrl(url).flatMap((filename) {
    final withoutExt = removeFileExtension(filename);
    final id = int.tryParse(withoutExt);
    if (id == null) {
      return left<String, int>(
        'Cannot parse image ID from filename: $withoutExt',
      );
    }
    return right(id);
  });
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

/// Converts a Dart object/map to query parameters for HTTP requests.
///
/// Handles list values by emitting multiple entries for the same key
/// (e.g., `{types: ['LORA', 'Checkpoint']}` → `types=LORA&types=Checkpoint`).
Map<String, dynamic> obj2QueryParams(Map<String, dynamic> params) {
  final result = <String, dynamic>{};
  for (final entry in params.entries) {
    if (entry.value == null) continue;
    if (entry.value is List) {
      // For lists, create a comma-joined string (CivitAI API format)
      result[entry.key] = (entry.value as List)
          .map((e) => e.toString())
          .join(',');
    } else {
      result[entry.key] = entry.value.toString();
    }
  }
  return result;
}
