// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ModelVersion {

 int get id; int get index; String get name; String get baseModel; String? get baseModelType; DateTime? get publishedAt; String get availability; int get nsfwLevel; String? get description; List<String> get trainedWords; ModelVersionStats get stats; List<ModelFile> get files; List<ModelImageWithId> get images;
/// Create a copy of ModelVersion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelVersionCopyWith<ModelVersion> get copyWith => _$ModelVersionCopyWithImpl<ModelVersion>(this as ModelVersion, _$identity);

  /// Serializes this ModelVersion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModelVersion&&(identical(other.id, id) || other.id == id)&&(identical(other.index, index) || other.index == index)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseModel, baseModel) || other.baseModel == baseModel)&&(identical(other.baseModelType, baseModelType) || other.baseModelType == baseModelType)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.nsfwLevel, nsfwLevel) || other.nsfwLevel == nsfwLevel)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.trainedWords, trainedWords)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other.files, files)&&const DeepCollectionEquality().equals(other.images, images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,index,name,baseModel,baseModelType,publishedAt,availability,nsfwLevel,description,const DeepCollectionEquality().hash(trainedWords),stats,const DeepCollectionEquality().hash(files),const DeepCollectionEquality().hash(images));

@override
String toString() {
  return 'ModelVersion(id: $id, index: $index, name: $name, baseModel: $baseModel, baseModelType: $baseModelType, publishedAt: $publishedAt, availability: $availability, nsfwLevel: $nsfwLevel, description: $description, trainedWords: $trainedWords, stats: $stats, files: $files, images: $images)';
}


}

/// @nodoc
abstract mixin class $ModelVersionCopyWith<$Res>  {
  factory $ModelVersionCopyWith(ModelVersion value, $Res Function(ModelVersion) _then) = _$ModelVersionCopyWithImpl;
@useResult
$Res call({
 int id, int index, String name, String baseModel, String? baseModelType, DateTime? publishedAt, String availability, int nsfwLevel, String? description, List<String> trainedWords, ModelVersionStats stats, List<ModelFile> files, List<ModelImageWithId> images
});


$ModelVersionStatsCopyWith<$Res> get stats;

}
/// @nodoc
class _$ModelVersionCopyWithImpl<$Res>
    implements $ModelVersionCopyWith<$Res> {
  _$ModelVersionCopyWithImpl(this._self, this._then);

  final ModelVersion _self;
  final $Res Function(ModelVersion) _then;

/// Create a copy of ModelVersion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? index = null,Object? name = null,Object? baseModel = null,Object? baseModelType = freezed,Object? publishedAt = freezed,Object? availability = null,Object? nsfwLevel = null,Object? description = freezed,Object? trainedWords = null,Object? stats = null,Object? files = null,Object? images = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseModel: null == baseModel ? _self.baseModel : baseModel // ignore: cast_nullable_to_non_nullable
as String,baseModelType: freezed == baseModelType ? _self.baseModelType : baseModelType // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as String,nsfwLevel: null == nsfwLevel ? _self.nsfwLevel : nsfwLevel // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,trainedWords: null == trainedWords ? _self.trainedWords : trainedWords // ignore: cast_nullable_to_non_nullable
as List<String>,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as ModelVersionStats,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<ModelFile>,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<ModelImageWithId>,
  ));
}
/// Create a copy of ModelVersion
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModelVersionStatsCopyWith<$Res> get stats {
  
  return $ModelVersionStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [ModelVersion].
extension ModelVersionPatterns on ModelVersion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModelVersion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModelVersion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModelVersion value)  $default,){
final _that = this;
switch (_that) {
case _ModelVersion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModelVersion value)?  $default,){
final _that = this;
switch (_that) {
case _ModelVersion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int index,  String name,  String baseModel,  String? baseModelType,  DateTime? publishedAt,  String availability,  int nsfwLevel,  String? description,  List<String> trainedWords,  ModelVersionStats stats,  List<ModelFile> files,  List<ModelImageWithId> images)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModelVersion() when $default != null:
return $default(_that.id,_that.index,_that.name,_that.baseModel,_that.baseModelType,_that.publishedAt,_that.availability,_that.nsfwLevel,_that.description,_that.trainedWords,_that.stats,_that.files,_that.images);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int index,  String name,  String baseModel,  String? baseModelType,  DateTime? publishedAt,  String availability,  int nsfwLevel,  String? description,  List<String> trainedWords,  ModelVersionStats stats,  List<ModelFile> files,  List<ModelImageWithId> images)  $default,) {final _that = this;
switch (_that) {
case _ModelVersion():
return $default(_that.id,_that.index,_that.name,_that.baseModel,_that.baseModelType,_that.publishedAt,_that.availability,_that.nsfwLevel,_that.description,_that.trainedWords,_that.stats,_that.files,_that.images);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int index,  String name,  String baseModel,  String? baseModelType,  DateTime? publishedAt,  String availability,  int nsfwLevel,  String? description,  List<String> trainedWords,  ModelVersionStats stats,  List<ModelFile> files,  List<ModelImageWithId> images)?  $default,) {final _that = this;
switch (_that) {
case _ModelVersion() when $default != null:
return $default(_that.id,_that.index,_that.name,_that.baseModel,_that.baseModelType,_that.publishedAt,_that.availability,_that.nsfwLevel,_that.description,_that.trainedWords,_that.stats,_that.files,_that.images);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModelVersion implements ModelVersion {
  const _ModelVersion({required this.id, required this.index, required this.name, required this.baseModel, this.baseModelType, this.publishedAt, this.availability = 'Public', required this.nsfwLevel, this.description, final  List<String> trainedWords = const [], this.stats = const ModelVersionStats(), final  List<ModelFile> files = const [], final  List<ModelImageWithId> images = const []}): _trainedWords = trainedWords,_files = files,_images = images;
  factory _ModelVersion.fromJson(Map<String, dynamic> json) => _$ModelVersionFromJson(json);

@override final  int id;
@override final  int index;
@override final  String name;
@override final  String baseModel;
@override final  String? baseModelType;
@override final  DateTime? publishedAt;
@override@JsonKey() final  String availability;
@override final  int nsfwLevel;
@override final  String? description;
 final  List<String> _trainedWords;
@override@JsonKey() List<String> get trainedWords {
  if (_trainedWords is EqualUnmodifiableListView) return _trainedWords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trainedWords);
}

@override@JsonKey() final  ModelVersionStats stats;
 final  List<ModelFile> _files;
@override@JsonKey() List<ModelFile> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}

 final  List<ModelImageWithId> _images;
@override@JsonKey() List<ModelImageWithId> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}


/// Create a copy of ModelVersion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelVersionCopyWith<_ModelVersion> get copyWith => __$ModelVersionCopyWithImpl<_ModelVersion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModelVersionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModelVersion&&(identical(other.id, id) || other.id == id)&&(identical(other.index, index) || other.index == index)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseModel, baseModel) || other.baseModel == baseModel)&&(identical(other.baseModelType, baseModelType) || other.baseModelType == baseModelType)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.nsfwLevel, nsfwLevel) || other.nsfwLevel == nsfwLevel)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._trainedWords, _trainedWords)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other._files, _files)&&const DeepCollectionEquality().equals(other._images, _images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,index,name,baseModel,baseModelType,publishedAt,availability,nsfwLevel,description,const DeepCollectionEquality().hash(_trainedWords),stats,const DeepCollectionEquality().hash(_files),const DeepCollectionEquality().hash(_images));

@override
String toString() {
  return 'ModelVersion(id: $id, index: $index, name: $name, baseModel: $baseModel, baseModelType: $baseModelType, publishedAt: $publishedAt, availability: $availability, nsfwLevel: $nsfwLevel, description: $description, trainedWords: $trainedWords, stats: $stats, files: $files, images: $images)';
}


}

/// @nodoc
abstract mixin class _$ModelVersionCopyWith<$Res> implements $ModelVersionCopyWith<$Res> {
  factory _$ModelVersionCopyWith(_ModelVersion value, $Res Function(_ModelVersion) _then) = __$ModelVersionCopyWithImpl;
@override @useResult
$Res call({
 int id, int index, String name, String baseModel, String? baseModelType, DateTime? publishedAt, String availability, int nsfwLevel, String? description, List<String> trainedWords, ModelVersionStats stats, List<ModelFile> files, List<ModelImageWithId> images
});


@override $ModelVersionStatsCopyWith<$Res> get stats;

}
/// @nodoc
class __$ModelVersionCopyWithImpl<$Res>
    implements _$ModelVersionCopyWith<$Res> {
  __$ModelVersionCopyWithImpl(this._self, this._then);

  final _ModelVersion _self;
  final $Res Function(_ModelVersion) _then;

/// Create a copy of ModelVersion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? index = null,Object? name = null,Object? baseModel = null,Object? baseModelType = freezed,Object? publishedAt = freezed,Object? availability = null,Object? nsfwLevel = null,Object? description = freezed,Object? trainedWords = null,Object? stats = null,Object? files = null,Object? images = null,}) {
  return _then(_ModelVersion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,baseModel: null == baseModel ? _self.baseModel : baseModel // ignore: cast_nullable_to_non_nullable
as String,baseModelType: freezed == baseModelType ? _self.baseModelType : baseModelType // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as String,nsfwLevel: null == nsfwLevel ? _self.nsfwLevel : nsfwLevel // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,trainedWords: null == trainedWords ? _self._trainedWords : trainedWords // ignore: cast_nullable_to_non_nullable
as List<String>,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as ModelVersionStats,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<ModelFile>,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<ModelImageWithId>,
  ));
}

/// Create a copy of ModelVersion
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModelVersionStatsCopyWith<$Res> get stats {
  
  return $ModelVersionStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// @nodoc
mixin _$Model {

 int get id; String get name; String? get description; String get type; bool get poi; bool get nsfw; int get nsfwLevel; Creator? get creator; ModelStats get stats; List<String> get tags; List<ModelVersion> get modelVersions;
/// Create a copy of Model
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelCopyWith<Model> get copyWith => _$ModelCopyWithImpl<Model>(this as Model, _$identity);

  /// Serializes this Model to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Model&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.poi, poi) || other.poi == poi)&&(identical(other.nsfw, nsfw) || other.nsfw == nsfw)&&(identical(other.nsfwLevel, nsfwLevel) || other.nsfwLevel == nsfwLevel)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.modelVersions, modelVersions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,type,poi,nsfw,nsfwLevel,creator,stats,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(modelVersions));

@override
String toString() {
  return 'Model(id: $id, name: $name, description: $description, type: $type, poi: $poi, nsfw: $nsfw, nsfwLevel: $nsfwLevel, creator: $creator, stats: $stats, tags: $tags, modelVersions: $modelVersions)';
}


}

/// @nodoc
abstract mixin class $ModelCopyWith<$Res>  {
  factory $ModelCopyWith(Model value, $Res Function(Model) _then) = _$ModelCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? description, String type, bool poi, bool nsfw, int nsfwLevel, Creator? creator, ModelStats stats, List<String> tags, List<ModelVersion> modelVersions
});


$CreatorCopyWith<$Res>? get creator;$ModelStatsCopyWith<$Res> get stats;

}
/// @nodoc
class _$ModelCopyWithImpl<$Res>
    implements $ModelCopyWith<$Res> {
  _$ModelCopyWithImpl(this._self, this._then);

  final Model _self;
  final $Res Function(Model) _then;

/// Create a copy of Model
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? type = null,Object? poi = null,Object? nsfw = null,Object? nsfwLevel = null,Object? creator = freezed,Object? stats = null,Object? tags = null,Object? modelVersions = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,poi: null == poi ? _self.poi : poi // ignore: cast_nullable_to_non_nullable
as bool,nsfw: null == nsfw ? _self.nsfw : nsfw // ignore: cast_nullable_to_non_nullable
as bool,nsfwLevel: null == nsfwLevel ? _self.nsfwLevel : nsfwLevel // ignore: cast_nullable_to_non_nullable
as int,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as Creator?,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as ModelStats,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,modelVersions: null == modelVersions ? _self.modelVersions : modelVersions // ignore: cast_nullable_to_non_nullable
as List<ModelVersion>,
  ));
}
/// Create a copy of Model
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreatorCopyWith<$Res>? get creator {
    if (_self.creator == null) {
    return null;
  }

  return $CreatorCopyWith<$Res>(_self.creator!, (value) {
    return _then(_self.copyWith(creator: value));
  });
}/// Create a copy of Model
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModelStatsCopyWith<$Res> get stats {
  
  return $ModelStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [Model].
extension ModelPatterns on Model {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Model value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Model() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Model value)  $default,){
final _that = this;
switch (_that) {
case _Model():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Model value)?  $default,){
final _that = this;
switch (_that) {
case _Model() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? description,  String type,  bool poi,  bool nsfw,  int nsfwLevel,  Creator? creator,  ModelStats stats,  List<String> tags,  List<ModelVersion> modelVersions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Model() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.type,_that.poi,_that.nsfw,_that.nsfwLevel,_that.creator,_that.stats,_that.tags,_that.modelVersions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? description,  String type,  bool poi,  bool nsfw,  int nsfwLevel,  Creator? creator,  ModelStats stats,  List<String> tags,  List<ModelVersion> modelVersions)  $default,) {final _that = this;
switch (_that) {
case _Model():
return $default(_that.id,_that.name,_that.description,_that.type,_that.poi,_that.nsfw,_that.nsfwLevel,_that.creator,_that.stats,_that.tags,_that.modelVersions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? description,  String type,  bool poi,  bool nsfw,  int nsfwLevel,  Creator? creator,  ModelStats stats,  List<String> tags,  List<ModelVersion> modelVersions)?  $default,) {final _that = this;
switch (_that) {
case _Model() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.type,_that.poi,_that.nsfw,_that.nsfwLevel,_that.creator,_that.stats,_that.tags,_that.modelVersions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Model implements Model {
  const _Model({required this.id, required this.name, this.description, this.type = 'Other', this.poi = false, this.nsfw = false, required this.nsfwLevel, this.creator, this.stats = const ModelStats(), final  List<String> tags = const [], final  List<ModelVersion> modelVersions = const []}): _tags = tags,_modelVersions = modelVersions;
  factory _Model.fromJson(Map<String, dynamic> json) => _$ModelFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? description;
@override@JsonKey() final  String type;
@override@JsonKey() final  bool poi;
@override@JsonKey() final  bool nsfw;
@override final  int nsfwLevel;
@override final  Creator? creator;
@override@JsonKey() final  ModelStats stats;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<ModelVersion> _modelVersions;
@override@JsonKey() List<ModelVersion> get modelVersions {
  if (_modelVersions is EqualUnmodifiableListView) return _modelVersions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_modelVersions);
}


/// Create a copy of Model
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelCopyWith<_Model> get copyWith => __$ModelCopyWithImpl<_Model>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Model&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.poi, poi) || other.poi == poi)&&(identical(other.nsfw, nsfw) || other.nsfw == nsfw)&&(identical(other.nsfwLevel, nsfwLevel) || other.nsfwLevel == nsfwLevel)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._modelVersions, _modelVersions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,type,poi,nsfw,nsfwLevel,creator,stats,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_modelVersions));

@override
String toString() {
  return 'Model(id: $id, name: $name, description: $description, type: $type, poi: $poi, nsfw: $nsfw, nsfwLevel: $nsfwLevel, creator: $creator, stats: $stats, tags: $tags, modelVersions: $modelVersions)';
}


}

/// @nodoc
abstract mixin class _$ModelCopyWith<$Res> implements $ModelCopyWith<$Res> {
  factory _$ModelCopyWith(_Model value, $Res Function(_Model) _then) = __$ModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? description, String type, bool poi, bool nsfw, int nsfwLevel, Creator? creator, ModelStats stats, List<String> tags, List<ModelVersion> modelVersions
});


@override $CreatorCopyWith<$Res>? get creator;@override $ModelStatsCopyWith<$Res> get stats;

}
/// @nodoc
class __$ModelCopyWithImpl<$Res>
    implements _$ModelCopyWith<$Res> {
  __$ModelCopyWithImpl(this._self, this._then);

  final _Model _self;
  final $Res Function(_Model) _then;

/// Create a copy of Model
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? type = null,Object? poi = null,Object? nsfw = null,Object? nsfwLevel = null,Object? creator = freezed,Object? stats = null,Object? tags = null,Object? modelVersions = null,}) {
  return _then(_Model(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,poi: null == poi ? _self.poi : poi // ignore: cast_nullable_to_non_nullable
as bool,nsfw: null == nsfw ? _self.nsfw : nsfw // ignore: cast_nullable_to_non_nullable
as bool,nsfwLevel: null == nsfwLevel ? _self.nsfwLevel : nsfwLevel // ignore: cast_nullable_to_non_nullable
as int,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as Creator?,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as ModelStats,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,modelVersions: null == modelVersions ? _self._modelVersions : modelVersions // ignore: cast_nullable_to_non_nullable
as List<ModelVersion>,
  ));
}

/// Create a copy of Model
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreatorCopyWith<$Res>? get creator {
    if (_self.creator == null) {
    return null;
  }

  return $CreatorCopyWith<$Res>(_self.creator!, (value) {
    return _then(_self.copyWith(creator: value));
  });
}/// Create a copy of Model
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModelStatsCopyWith<$Res> get stats {
  
  return $ModelStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// @nodoc
mixin _$ModelsResponse {

 List<Model> get items; PaginationMetadata get metadata;
/// Create a copy of ModelsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelsResponseCopyWith<ModelsResponse> get copyWith => _$ModelsResponseCopyWithImpl<ModelsResponse>(this as ModelsResponse, _$identity);

  /// Serializes this ModelsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModelsResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),metadata);

@override
String toString() {
  return 'ModelsResponse(items: $items, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $ModelsResponseCopyWith<$Res>  {
  factory $ModelsResponseCopyWith(ModelsResponse value, $Res Function(ModelsResponse) _then) = _$ModelsResponseCopyWithImpl;
@useResult
$Res call({
 List<Model> items, PaginationMetadata metadata
});


$PaginationMetadataCopyWith<$Res> get metadata;

}
/// @nodoc
class _$ModelsResponseCopyWithImpl<$Res>
    implements $ModelsResponseCopyWith<$Res> {
  _$ModelsResponseCopyWithImpl(this._self, this._then);

  final ModelsResponse _self;
  final $Res Function(ModelsResponse) _then;

/// Create a copy of ModelsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Model>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as PaginationMetadata,
  ));
}
/// Create a copy of ModelsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginationMetadataCopyWith<$Res> get metadata {
  
  return $PaginationMetadataCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [ModelsResponse].
extension ModelsResponsePatterns on ModelsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModelsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModelsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModelsResponse value)  $default,){
final _that = this;
switch (_that) {
case _ModelsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModelsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ModelsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Model> items,  PaginationMetadata metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModelsResponse() when $default != null:
return $default(_that.items,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Model> items,  PaginationMetadata metadata)  $default,) {final _that = this;
switch (_that) {
case _ModelsResponse():
return $default(_that.items,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Model> items,  PaginationMetadata metadata)?  $default,) {final _that = this;
switch (_that) {
case _ModelsResponse() when $default != null:
return $default(_that.items,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModelsResponse implements ModelsResponse {
  const _ModelsResponse({required final  List<Model> items, this.metadata = const PaginationMetadata()}): _items = items;
  factory _ModelsResponse.fromJson(Map<String, dynamic> json) => _$ModelsResponseFromJson(json);

 final  List<Model> _items;
@override List<Model> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  PaginationMetadata metadata;

/// Create a copy of ModelsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelsResponseCopyWith<_ModelsResponse> get copyWith => __$ModelsResponseCopyWithImpl<_ModelsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModelsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModelsResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),metadata);

@override
String toString() {
  return 'ModelsResponse(items: $items, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$ModelsResponseCopyWith<$Res> implements $ModelsResponseCopyWith<$Res> {
  factory _$ModelsResponseCopyWith(_ModelsResponse value, $Res Function(_ModelsResponse) _then) = __$ModelsResponseCopyWithImpl;
@override @useResult
$Res call({
 List<Model> items, PaginationMetadata metadata
});


@override $PaginationMetadataCopyWith<$Res> get metadata;

}
/// @nodoc
class __$ModelsResponseCopyWithImpl<$Res>
    implements _$ModelsResponseCopyWith<$Res> {
  __$ModelsResponseCopyWithImpl(this._self, this._then);

  final _ModelsResponse _self;
  final $Res Function(_ModelsResponse) _then;

/// Create a copy of ModelsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? metadata = null,}) {
  return _then(_ModelsResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Model>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as PaginationMetadata,
  ));
}

/// Create a copy of ModelsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginationMetadataCopyWith<$Res> get metadata {
  
  return $PaginationMetadataCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}

// dart format on
