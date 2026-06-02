import 'package:test/test.dart';

import 'package:flutter_civitai_box/civitai_api/utils.dart';
import 'package:flutter_civitai_box/civitai_api/models/model_id.dart';
import 'package:flutter_civitai_box/civitai_api/models/shared.dart';

void main() {
  group('extractFilenameFromUrl', () {
    test('extracts filename from standard URL', () {
      final result = extractFilenameFromUrl(
        'https://image.civitai.com/x/width=1024/1743606.jpeg',
      );
      expect(result, '1743606.jpeg');
    });

    test('extracts filename without query params', () {
      final result = extractFilenameFromUrl(
        'https://example.com/path/to/file.safetensors?token=abc',
      );
      expect(result, 'file.safetensors');
    });

    test('returns null for URL without path', () {
      final result = extractFilenameFromUrl('https://example.com');
      expect(result, isNull);
    });

    test('handles URL with fragment', () {
      final result = extractFilenameFromUrl(
        'https://example.com/file.txt#section',
      );
      expect(result, 'file.txt');
    });

    test('returns null for invalid URL', () {
      final result = extractFilenameFromUrl('not-a-url');
      expect(result, isNull);
    });
  });

  group('removeFileExtension', () {
    test('removes extension', () {
      expect(removeFileExtension('1743606.jpeg'), '1743606');
      expect(removeFileExtension('model.safetensors'), 'model');
    });

    test('handles no extension', () {
      expect(removeFileExtension('noext'), 'noext');
    });

    test('handles path with directories', () {
      expect(removeFileExtension('path/to/file.txt'), 'path/to/file');
    });

    test('handles hidden files (dot prefix)', () {
      expect(removeFileExtension('.gitignore'), '');
    });
  });

  group('extractIdFromImageUrl', () {
    test('extracts numeric ID from CivitAI image URL', () {
      final result = extractIdFromImageUrl(
        'https://image.civitai.com/xG1nkqKTMzGDvpLrqFT7WA/cbe20dcf-7721-4f34-bc24-9ff14b96cab2/width=1024/1743606.jpeg',
      );
      expect(result, 1743606);
    });

    test('returns null for invalid URL', () {
      final result = extractIdFromImageUrl('not-a-url');
      expect(result, isNull);
    });

    test('returns null for non-numeric filename', () {
      final result = extractIdFromImageUrl(
        'https://image.civitai.com/x/width=1024/notanumber.jpeg',
      );
      expect(result, isNull);
    });
  });

  group('getFileType', () {
    test('identifies image types', () {
      expect(getFileType('photo.jpg'), 'image');
      expect(getFileType('photo.jpeg'), 'image');
      expect(getFileType('photo.png'), 'image');
      expect(getFileType('photo.webp'), 'image');
      expect(getFileType('photo.avif'), 'image');
    });

    test('identifies video types', () {
      expect(getFileType('clip.mp4'), 'video');
      expect(getFileType('clip.webm'), 'video');
      expect(getFileType('clip.mov'), 'video');
    });

    test('returns unknown for other extensions', () {
      expect(getFileType('doc.pdf'), 'unknown');
      expect(getFileType('model.safetensors'), 'unknown');
    });

    test('returns unknown for empty string', () {
      expect(getFileType(''), 'unknown');
    });
  });

  group('obj2QueryParams', () {
    test('converts simple key-value pairs to strings', () {
      final result = obj2QueryParams({'limit': 10, 'query': 'pony'});
      expect(result['limit'], '10');
      expect(result['query'], 'pony');
    });

    test('joins list values with comma', () {
      final result = obj2QueryParams({
        'types': ['LORA', 'Checkpoint'],
      });
      expect(result['types'], 'LORA,Checkpoint');
    });

    test('skips null values', () {
      final result = obj2QueryParams({'a': 1, 'b': null, 'c': 'hello'});
      expect(result.containsKey('a'), true);
      expect(result.containsKey('b'), false);
      expect(result.containsKey('c'), true);
    });

    test('handles empty map', () {
      expect(obj2QueryParams({}), {});
    });

    test('converts bool to string', () {
      final result = obj2QueryParams({'nsfw': true});
      expect(result['nsfw'], 'true');
    });
  });

  group('modelId2Model', () {
    test('converts ModelById with images to Model', () {
      final modelById = ModelById(
        id: 123,
        name: 'Test Model',
        nsfwLevel: 1,
        modelVersions: [
          ModelByIdVersion(
            id: 1,
            index: 0,
            name: 'v1',
            baseModel: 'SD 1.5',
            nsfwLevel: 0,
            images: [
              ModelImage(
                url: 'https://image.civitai.com/x/width=1024/42.jpeg',
                nsfwLevel: 0,
                width: 1024,
                height: 768,
                hash: 'abc',
                type: 'image',
              ),
            ],
          ),
        ],
      );

      final model = modelId2Model(modelById);
      expect(model.id, 123);
      expect(model.name, 'Test Model');
      expect(model.modelVersions.length, 1);
      expect(model.modelVersions[0].images.length, 1);
      expect(model.modelVersions[0].images[0].id, 42);
    });

    test('handles image URL without numeric ID (id becomes 0)', () {
      final modelById = ModelById(
        id: 1,
        name: 'M',
        nsfwLevel: 0,
        modelVersions: [
          ModelByIdVersion(
            id: 1,
            index: 0,
            name: 'v',
            baseModel: 'SD 1.5',
            nsfwLevel: 0,
            images: [
              ModelImage(
                url: 'https://image.civitai.com/x/width=1024/notanumber.jpeg',
                nsfwLevel: 0,
                width: 512,
                height: 512,
                hash: 'h',
                type: 'image',
              ),
            ],
          ),
        ],
      );

      final model = modelId2Model(modelById);
      expect(model.modelVersions[0].images[0].id, 0);
    });

    test('preserves ModelStats, tags, and creator', () {
      final modelById = ModelById(
        id: 99,
        name: 'Rich Model',
        description: 'Has everything',
        type: 'LORA',
        poi: true,
        nsfw: true,
        nsfwLevel: 2,
        stats: ModelStats(
          downloadCount: 1000,
          thumbsUpCount: 100,
          commentCount: 10,
          tippedAmountCount: 5,
        ),
        tags: ['anime', 'style'],
        modelVersions: [],
      );

      final model = modelId2Model(modelById);
      expect(model.description, 'Has everything');
      expect(model.type, 'LORA');
      expect(model.poi, true);
      expect(model.stats.downloadCount, 1000);
      expect(model.tags, ['anime', 'style']);
    });

    test('handles multiple versions', () {
      final modelById = ModelById(
        id: 1,
        name: 'Multi',
        nsfwLevel: 0,
        modelVersions: [
          ModelByIdVersion(
            id: 1,
            index: 0,
            name: 'v1',
            baseModel: 'SD 1.5',
            nsfwLevel: 0,
          ),
          ModelByIdVersion(
            id: 2,
            index: 1,
            name: 'v2',
            baseModel: 'SDXL 1.0',
            nsfwLevel: 1,
          ),
        ],
      );

      final model = modelId2Model(modelById);
      expect(model.modelVersions.length, 2);
    });
  });
}
