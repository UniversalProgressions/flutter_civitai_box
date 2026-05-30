// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model_version.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ModelVersionEndpointData {

 int get id; int get modelId; String get name; String get baseModel; String? get baseModelType; DateTime get publishedAt; int get nsfwLevel; String? get description; List<String> get trainedWords; ModelVersionEndpointStats get stats; List<ModelFile> get files; List<ModelImage> get images;
/// Create a copy of ModelVersionEndpointData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelVersionEndpointDataCopyWith<ModelVersionEndpointData> get copyWith => _$ModelVersionEndpointDataCopyWithImpl<ModelVersionEndpointData>(this as ModelVersionEndpointData, _$identity);

  /// Serializes this ModelVersionEndpointData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModelVersionEndpointData&&(identical(other.id, id) || other.id == id)&&(identical(other.modelId, modelId) || other.modelId == modelId)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseModel, baseModel) || other.baseModel == baseModel)&&(identical(other.baseModelType, baseModelType) || other.baseModelType == baseModelType)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.nsfwLevel, nsfwLevel) || other.nsfwLevel == nsfwLevel)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.trainedWords, trainedWords)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other.files, files)&&const DeepCollectionEquality().equals(other.images, images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,modelId,name,baseModel,baseModelType,publishedAt,nsfwLevel,description,const DeepCollectionEquality().hash(trainedWords),stats,const DeepCollectionEquality().hash(files),const DeepCollectionEquality().hash(images));

@override
String toString() {
  return 'ModelVersionEndpointData(id: $id, modelId: $modelId, name: $name, baseModel: $baseModel, baseModelType: $baseModelType, publishedAt: $publishedAt, nsfwLevel: $nsfwLevel, description: $description, trainedWords: $trainedWords, stats: $stats, files: $files, images: $images)';
}


}

/// @nodoc
abstract mixin class $ModelVersionEndpointDataCopyWith<$Res>  {
  factory $ModelVersionEndpointDataCopyWith(ModelVersionEndpointData value, $Res Function(ModelVersionEndpointData) _then) = _$ModelVersionEndpointDataCopyWithImpl;
@useResult
$Res call({
 int id, int modelId, String name, String baseModel, String? baseModelType, DateTime publishedAt, int nsfwLevel, String? description, List<String> trainedWords, ModelVersionEndpointStats stats, List<ModelFile> files, List<ModelImage> images
});


$ModelVersionEndpointStatsCopyWith<$Res> get stats;

}
/// @nodoc
class _$ModelVersionEndpointDataCopyWithImpl<$Res>
    implements $ModelVersionEndpointDataCopyWith<$Res> {
  _$ModelVersionEndpointDataCopyWithImpl(this._self, this._then);

  final ModelVersionEndpointData _self;
  final $Res Function(ModelVersionEndpointData) _then;

/// Create a copy of ModelVersionEndpointData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? modelId = null,Object? name = null,Object? baseModel = null,Object? baseModelType = freezed,Object? publishedAt = null,Object? nsfwLevel = null,Object? description = freezed,Object? trainedWords = null,Object? stats = null,Object? files = null,Object? images = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,modelId: null == modelId ? _self.modelId : modelId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseModel: null == baseModel ? _self.baseModel : baseModel // ignore: cast_nullable_to_non_nullable
as String,baseModelType: freezed == baseModelType ? _self.baseModelType : baseModelType // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,nsfwLevel: null == nsfwLevel ? _self.nsfwLevel : nsfwLevel // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,trainedWords: null == trainedWords ? _self.trainedWords : trainedWords // ignore: cast_nullable_to_non_nullable
as List<String>,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as ModelVersionEndpointStats,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<ModelFile>,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<ModelImage>,
  ));
}
/// Create a copy of ModelVersionEndpointData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModelVersionEndpointStatsCopyWith<$Res> get stats {
  
  return $ModelVersionEndpointStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [ModelVersionEndpointData].
extension ModelVersionEndpointDataPatterns on ModelVersionEndpointData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModelVersionEndpointData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModelVersionEndpointData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModelVersionEndpointData value)  $default,){
final _that = this;
switch (_that) {
case _ModelVersionEndpointData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModelVersionEndpointData value)?  $default,){
final _that = this;
switch (_that) {
case _ModelVersionEndpointData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int modelId,  String name,  String baseModel,  String? baseModelType,  DateTime publishedAt,  int nsfwLevel,  String? description,  List<String> trainedWords,  ModelVersionEndpointStats stats,  List<ModelFile> files,  List<ModelImage> images)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModelVersionEndpointData() when $default != null:
return $default(_that.id,_that.modelId,_that.name,_that.baseModel,_that.baseModelType,_that.publishedAt,_that.nsfwLevel,_that.description,_that.trainedWords,_that.stats,_that.files,_that.images);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int modelId,  String name,  String baseModel,  String? baseModelType,  DateTime publishedAt,  int nsfwLevel,  String? description,  List<String> trainedWords,  ModelVersionEndpointStats stats,  List<ModelFile> files,  List<ModelImage> images)  $default,) {final _that = this;
switch (_that) {
case _ModelVersionEndpointData():
return $default(_that.id,_that.modelId,_that.name,_that.baseModel,_that.baseModelType,_that.publishedAt,_that.nsfwLevel,_that.description,_that.trainedWords,_that.stats,_that.files,_that.images);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int modelId,  String name,  String baseModel,  String? baseModelType,  DateTime publishedAt,  int nsfwLevel,  String? description,  List<String> trainedWords,  ModelVersionEndpointStats stats,  List<ModelFile> files,  List<ModelImage> images)?  $default,) {final _that = this;
switch (_that) {
case _ModelVersionEndpointData() when $default != null:
return $default(_that.id,_that.modelId,_that.name,_that.baseModel,_that.baseModelType,_that.publishedAt,_that.nsfwLevel,_that.description,_that.trainedWords,_that.stats,_that.files,_that.images);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModelVersionEndpointData implements ModelVersionEndpointData {
  const _ModelVersionEndpointData({required this.id, required this.modelId, required this.name, required this.baseModel, this.baseModelType, required this.publishedAt, required this.nsfwLevel, this.description, final  List<String> trainedWords = const [], this.stats = const ModelVersionEndpointStats(), final  List<ModelFile> files = const [], final  List<ModelImage> images = const []}): _trainedWords = trainedWords,_files = files,_images = images;
  factory _ModelVersionEndpointData.fromJson(Map<String, dynamic> json) => _$ModelVersionEndpointDataFromJson(json);

@override final  int id;
@override final  int modelId;
@override final  String name;
@override final  String baseModel;
@override final  String? baseModelType;
@override final  DateTime publishedAt;
@override final  int nsfwLevel;
@override final  String? description;
 final  List<String> _trainedWords;
@override@JsonKey() List<String> get trainedWords {
  if (_trainedWords is EqualUnmodifiableListView) return _trainedWords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trainedWords);
}

@override@JsonKey() final  ModelVersionEndpointStats stats;
 final  List<ModelFile> _files;
@override@JsonKey() List<ModelFile> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}

 final  List<ModelImage> _images;
@override@JsonKey() List<ModelImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}


/// Create a copy of ModelVersionEndpointData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelVersionEndpointDataCopyWith<_ModelVersionEndpointData> get copyWith => __$ModelVersionEndpointDataCopyWithImpl<_ModelVersionEndpointData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModelVersionEndpointDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModelVersionEndpointData&&(identical(other.id, id) || other.id == id)&&(identical(other.modelId, modelId) || other.modelId == modelId)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseModel, baseModel) || other.baseModel == baseModel)&&(identical(other.baseModelType, baseModelType) || other.baseModelType == baseModelType)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.nsfwLevel, nsfwLevel) || other.nsfwLevel == nsfwLevel)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._trainedWords, _trainedWords)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other._files, _files)&&const DeepCollectionEquality().equals(other._images, _images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,modelId,name,baseModel,baseModelType,publishedAt,nsfwLevel,description,const DeepCollectionEquality().hash(_trainedWords),stats,const DeepCollectionEquality().hash(_files),const DeepCollectionEquality().hash(_images));

@override
String toString() {
  return 'ModelVersionEndpointData(id: $id, modelId: $modelId, name: $name, baseModel: $baseModel, baseModelType: $baseModelType, publishedAt: $publishedAt, nsfwLevel: $nsfwLevel, description: $description, trainedWords: $trainedWords, stats: $stats, files: $files, images: $images)';
}


}

/// @nodoc
abstract mixin class _$ModelVersionEndpointDataCopyWith<$Res> implements $ModelVersionEndpointDataCopyWith<$Res> {
  factory _$ModelVersionEndpointDataCopyWith(_ModelVersionEndpointData value, $Res Function(_ModelVersionEndpointData) _then) = __$ModelVersionEndpointDataCopyWithImpl;
@override @useResult
$Res call({
 int id, int modelId, String name, String baseModel, String? baseModelType, DateTime publishedAt, int nsfwLevel, String? description, List<String> trainedWords, ModelVersionEndpointStats stats, List<ModelFile> files, List<ModelImage> images
});


@override $ModelVersionEndpointStatsCopyWith<$Res> get stats;

}
/// @nodoc
class __$ModelVersionEndpointDataCopyWithImpl<$Res>
    implements _$ModelVersionEndpointDataCopyWith<$Res> {
  __$ModelVersionEndpointDataCopyWithImpl(this._self, this._then);

  final _ModelVersionEndpointData _self;
  final $Res Function(_ModelVersionEndpointData) _then;

/// Create a copy of ModelVersionEndpointData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? modelId = null,Object? name = null,Object? baseModel = null,Object? baseModelType = freezed,Object? publishedAt = null,Object? nsfwLevel = null,Object? description = freezed,Object? trainedWords = null,Object? stats = null,Object? files = null,Object? images = null,}) {
  return _then(_ModelVersionEndpointData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,modelId: null == modelId ? _self.modelId : modelId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseModel: null == baseModel ? _self.baseModel : baseModel // ignore: cast_nullable_to_non_nullable
as String,baseModelType: freezed == baseModelType ? _self.baseModelType : baseModelType // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,nsfwLevel: null == nsfwLevel ? _self.nsfwLevel : nsfwLevel // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,trainedWords: null == trainedWords ? _self._trainedWords : trainedWords // ignore: cast_nullable_to_non_nullable
as List<String>,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as ModelVersionEndpointStats,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<ModelFile>,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<ModelImage>,
  ));
}

/// Create a copy of ModelVersionEndpointData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModelVersionEndpointStatsCopyWith<$Res> get stats {
  
  return $ModelVersionEndpointStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}

// dart format on
