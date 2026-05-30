import 'package:test/test.dart';

import 'package:flutter_civitai_box/civitai_api/models/enums.dart';

void main() {
  group('ModelType', () {
    test('all values have unique string representations', () {
      final values = ModelType.values.map((e) => e.value).toList();
      expect(values.toSet().length, values.length);
    });

    test('fromString matches each value', () {
      for (final type in ModelType.values) {
        expect(ModelType.fromString(type.value), type);
      }
    });

    test('fromString throws on unknown value', () {
      expect(
        () => ModelType.fromString('NotARealType'),
        throwsA(isA<StateError>()),
      );
    });

    test('LORA is present', () {
      expect(ModelType.fromString('LORA'), ModelType.lora);
    });

    test('Checkpoint is present', () {
      expect(ModelType.fromString('Checkpoint'), ModelType.checkpoint);
    });
  });

  group('ModelsSort', () {
    test('all three values exist', () {
      expect(ModelsSort.values.length, 3);
      expect(ModelsSort.highestRated.value, 'Highest Rated');
      expect(ModelsSort.mostDownloaded.value, 'Most Downloaded');
      expect(ModelsSort.newest.value, 'Newest');
    });
  });

  group('ModelsPeriod', () {
    test('all five values exist', () {
      expect(ModelsPeriod.values.length, 5);
      expect(ModelsPeriod.allTime.value, 'AllTime');
      expect(ModelsPeriod.month.value, 'Month');
    });
  });

  group('NsfwLevel', () {
    test('five levels', () {
      expect(NsfwLevel.values.length, 5);
    });

    test('mapping is correct', () {
      expect(NsfwLevel.none.value, 'None');
      expect(NsfwLevel.x.value, 'X');
    });
  });

  group('AllowCommercialUse', () {
    test('five values', () {
      expect(AllowCommercialUse.values.length, 5);
    });

    test('Image and Sell are present', () {
      expect(AllowCommercialUse.image.value, 'Image');
      expect(AllowCommercialUse.sell.value, 'Sell');
    });
  });

  group('CheckpointType', () {
    test('two values', () {
      expect(CheckpointType.values.length, 2);
      expect(CheckpointType.merge.value, 'Merge');
      expect(CheckpointType.trained.value, 'Trained');
    });
  });

  group('BaseModel', () {
    test('has expected models', () {
      expect(BaseModel.fromString('SD 1.5'), BaseModel.sd15);
      expect(BaseModel.fromString('SDXL 1.0'), BaseModel.sdxl10);
      expect(BaseModel.fromString('Pony'), BaseModel.pony);
      expect(BaseModel.fromString('Flux .1 D'), BaseModel.flux1D);
      expect(BaseModel.fromString('Illustrious'), BaseModel.illustrious);
    });

    test('fromString throws on unknown', () {
      expect(
        () => BaseModel.fromString('UnknownModel'),
        throwsA(isA<StateError>()),
      );
    });

    test('all values map back via fromString', () {
      for (final bm in BaseModel.values) {
        expect(BaseModel.fromString(bm.value), bm);
      }
    });
  });
}
