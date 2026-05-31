/// Enum types matching CivitAI API values.
///
/// These are plain Dart enums — no Freezed needed since they are simple
/// value types with fixed sets of possible values.
library;

/// Model type categories on CivitAI.
enum ModelType {
  checkpoint('Checkpoint'),
  textualInversion('TextualInversion'),
  hypernetwork('Hypernetwork'),
  aestheticGradient('AestheticGradient'),
  lora('LORA'),
  controlnet('Controlnet'),
  poses('Poses'),
  loCon('LoCon'),
  doRA('DoRA'),
  other('Other'),
  motionModule('MotionModule'),
  upscaler('Upscaler'),
  vae('VAE'),
  wildcards('Wildcards'),
  workflows('Workflows'),
  detection('Detection');

  const ModelType(this.value);
  final String value;

  static ModelType fromString(String s) =>
      ModelType.values.firstWhere((e) => e.value == s);
}

/// Sort order for model listings.
enum ModelsSort {
  highestRated('Highest Rated'),
  mostDownloaded('Most Downloaded'),
  newest('Newest');

  const ModelsSort(this.value);
  final String value;
}

/// Time period for filtering/sorting models.
enum ModelsPeriod {
  allTime('AllTime'),
  day('Day'),
  week('Week'),
  month('Month'),
  year('Year');

  const ModelsPeriod(this.value);
  final String value;
}

/// NSFW content level.
enum NsfwLevel {
  none('None'),
  soft('Soft'),
  mature('Mature'),
  x('X'),
  blocked('Blocked');

  const NsfwLevel(this.value);
  final String value;
}

/// Commercial use permission level.
enum AllowCommercialUse {
  image('Image'),
  rentCivit('RentCivit'),
  rent('Rent'),
  sell('Sell'),
  none('None');

  const AllowCommercialUse(this.value);
  final String value;
}

/// Checkpoint type (merge or trained).
enum CheckpointType {
  merge('Merge'),
  trained('Trained');

  const CheckpointType(this.value);
  final String value;
}

/// Base model architecture.
enum BaseModel {
  auraFlow('Aura Flow'),
  cogVideoX('CogVideoX'),
  flux1D('Flux .1 D'),
  flux1S('Flux .1 S'),
  hiDream('HiDream'),
  hunyuan1('Hunyuan 1'),
  hunyuanVideo('Hunyuan Video'),
  illustrious('Illustrious'),
  kolors('Kolors'),
  ltxv('LTXV'),
  lumina('Lumina'),
  mochi('Mochi'),
  noobAI('NoobAI'),
  odor('ODOR'),
  openAI('Open AI'),
  other('Other'),
  pixArtE('PixArt E'),
  pixArtA('PixArt a'),
  playgroundV2('Playground v2'),
  pony('Pony'),
  sd14('SD 1.4'),
  sd15('SD 1.5'),
  sd15Hyper('SD 1.5 Hyper'),
  sd15LCM('SD 1.5 LCM'),
  sd20('SD 2.0'),
  sd20768('SD 2.0 768'),
  sd21('SD 2.1'),
  sd21768('SD 2.1 768'),
  sd21Unclip('SD 2.1 Unclip'),
  sd3('SD 3'),
  sd35('SD 3.5'),
  sd35Large('SD 3.5 Large'),
  sd35LargeTurbo('SD 3.5 Large Turbo'),
  sd35Medium('SD 3.5 Medium'),
  sdxl09('SDXL 0.9'),
  sdxl10('SDXL 1.0'),
  sdxl10LCM('SDXL 1.0 LCM'),
  sdxlDistilled('SDXL Distilled'),
  sdxlHyper('SDXL Hyper'),
  sdxlLightning('SDXL Lightning'),
  sdxlTurbo('SDXL Turbo'),
  svd('SVD'),
  svdXT('SVD XT'),
  stableCascade('Stable Cascade'),
  wanVideo('WAN Video');

  const BaseModel(this.value);
  final String value;

  static BaseModel fromString(String s) =>
      BaseModel.values.firstWhere((e) => e.value == s);
}
