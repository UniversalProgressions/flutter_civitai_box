import 'package:test/test.dart';

import 'package:flutter_civitai_box/civitai_api/models/shared.dart';

void main() {
  group('FileHashes', () {
    test('fromJson with all fields', () {
      final json = {
        'sha256': 'abc123',
        'crc32': 'def456',
        'blake3': 'ghi789',
        'autoV3': 'v3hash',
        'autoV2': 'v2hash',
        'autoV1': 'v1hash',
      };
      final hashes = FileHashes.fromJson(json);
      expect(hashes.sha256, 'abc123');
      expect(hashes.crc32, 'def456');
      expect(hashes.blake3, 'ghi789');
      expect(hashes.autoV3, 'v3hash');
      expect(hashes.autoV2, 'v2hash');
      expect(hashes.autoV1, 'v1hash');
    });

    test('fromJson with missing fields', () {
      final hashes = FileHashes.fromJson({});
      expect(hashes.sha256, isNull);
      expect(hashes.crc32, isNull);
    });

    test('copyWith works', () {
      final h = FileHashes(sha256: 'old');
      expect(h.copyWith(sha256: 'new').sha256, 'new');
    });
  });

  group('FileMetadata', () {
    test('fromJson', () {
      final json = {'fp': 'fp16', 'size': 'full', 'format': 'SafeTensor'};
      final meta = FileMetadata.fromJson(json);
      expect(meta.fp, 'fp16');
      expect(meta.size, 'full');
      expect(meta.format, 'SafeTensor');
    });

    test('defaults are null', () {
      final meta = FileMetadata();
      expect(meta.fp, isNull);
      expect(meta.size, isNull);
      expect(meta.format, isNull);
    });
  });

  group('ModelFile', () {
    test('fromJson parses required fields', () {
      final json = {
        'id': 1,
        'sizeKB': 1024.5,
        'name': 'model.safetensors',
        'type': 'Model',
        'downloadUrl': 'https://example.com/file',
      };
      final file = ModelFile.fromJson(json);
      expect(file.id, 1);
      expect(file.sizeKB, 1024.5);
      expect(file.name, 'model.safetensors');
      expect(file.type, 'Model');
      expect(file.downloadUrl, 'https://example.com/file');
    });

    test('fromJson with scannedAt (ISO date)', () {
      final json = {
        'id': 1,
        'sizeKB': 100,
        'name': 'f',
        'type': 'Model',
        'downloadUrl': 'https://x.com/f',
        'scannedAt': '2025-01-15T10:30:00.000Z',
      };
      final file = ModelFile.fromJson(json);
      expect(file.scannedAt, isNotNull);
      expect(file.scannedAt!.year, 2025);
    });

    test('fromJson with hashes', () {
      final json = {
        'id': 1,
        'sizeKB': 100,
        'name': 'f',
        'type': 'Model',
        'downloadUrl': 'https://x.com/f',
        'hashes': {'sha256': 'abc'},
      };
      final file = ModelFile.fromJson(json);
      expect(file.hashes?.sha256, 'abc');
    });
  });

  group('ModelImage', () {
    test('fromJson', () {
      final json = {
        'url': 'https://img.example.com/1.jpg',
        'nsfwLevel': 0,
        'width': 1024,
        'height': 768,
        'hash': 'imghash',
        'type': 'image',
      };
      final img = ModelImage.fromJson(json);
      expect(img.url, 'https://img.example.com/1.jpg');
      expect(img.nsfwLevel, 0);
      expect(img.width, 1024);
      expect(img.height, 768);
      expect(img.hash, 'imghash');
      expect(img.type, 'image');
    });
  });

  group('ModelImageWithId', () {
    test('fromJson includes id', () {
      final json = {
        'id': 42,
        'url': 'https://img.example.com/1.jpg',
        'nsfwLevel': 1,
        'width': 512,
        'height': 512,
        'hash': 'h',
        'type': 'image',
      };
      final img = ModelImageWithId.fromJson(json);
      expect(img.id, 42);
      expect(img.url, 'https://img.example.com/1.jpg');
    });
  });

  group('ModelVersionStats', () {
    test('fromJson', () {
      final json = {
        'downloadCount': 1000,
        'thumbsUpCount': 50,
        'thumbsDownCount': 2,
      };
      final stats = ModelVersionStats.fromJson(json);
      expect(stats.downloadCount, 1000);
      expect(stats.thumbsUpCount, 50);
      expect(stats.thumbsDownCount, 2);
    });
  });

  group('ModelVersionEndpointStats', () {
    test('fromJson — no thumbsDownCount', () {
      final json = {'downloadCount': 500, 'thumbsUpCount': 25, 'rating': 4.5};
      final stats = ModelVersionEndpointStats.fromJson(json);
      expect(stats.downloadCount, 500);
      expect(stats.thumbsUpCount, 25);
      expect(stats.rating, 4.5);
    });
  });

  group('ModelStats', () {
    test('fromJson', () {
      final json = {
        'downloadCount': 5000,
        'favoriteCount': 120,
        'thumbsUpCount': 300,
        'commentCount': 45,
        'tippedAmountCount': 10,
      };
      final stats = ModelStats.fromJson(json);
      expect(stats.downloadCount, 5000);
      expect(stats.favoriteCount, 120);
      expect(stats.thumbsUpCount, 300);
      expect(stats.commentCount, 45);
      expect(stats.tippedAmountCount, 10);
    });
  });

  group('PaginationMetadata', () {
    test('fromJson with all fields', () {
      final json = {
        'totalItems': 200,
        'currentPage': 1,
        'pageSize': 100,
        'totalPages': 2,
        'nextPage': 'https://civitai.com/api/v1/models?page=2',
        'prevPage': null,
      };
      final meta = PaginationMetadata.fromJson(json);
      expect(meta.totalItems, 200);
      expect(meta.currentPage, 1);
      expect(meta.pageSize, 100);
      expect(meta.totalPages, 2);
      expect(meta.nextPage, 'https://civitai.com/api/v1/models?page=2');
      expect(meta.prevPage, isNull);
    });

    test('fromJson empty', () {
      final meta = PaginationMetadata.fromJson({});
      expect(meta.totalItems, isNull);
      expect(meta.currentPage, isNull);
    });
  });
}
