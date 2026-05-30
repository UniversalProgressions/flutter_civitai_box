// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model_id.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ModelByIdVersion {

 int get id; int get index; String get name; String get baseModel; String? get baseModelType; DateTime? get publishedAt; String get availability; int get nsfwLevel; String? get description; List<String> get trainedWords; ModelVersionStats get stats; List<ModelFile> get files; List<ModelImage> get images;
/// Create a copy of ModelByIdVersion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelByIdVersionCopyWith<ModelByIdVersion> get copyWith => _$ModelByIdVersionCopyWithImpl<ModelByIdVersion>(this as ModelByIdVersion, _$identity);

  /// Serializes this ModelByIdVersion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModelByIdVersion&&(identical(other.id, id) || other.id == id)&&(identical(other.index, index) || other.index == index)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseModel, baseModel) || other.baseModel == baseModel)&&(identical(other.baseModelType, baseModelType) || other.baseModelType == baseModelType)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.nsfwLevel, nsfwLevel) || other.nsfwLevel == nsfwLevel)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.trainedWords, trainedWords)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other.files, files)&&const DeepCollectionEquality().equals(other.images, images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,index,name,baseModel,baseModelType,publishedAt,availability,nsfwLevel,description,const DeepCollectionEquality().hash(trainedWords),stats,const DeepCollectionEquality().hash(files),const DeepCollectionEquality().hash(images));

@override
String toString() {
  return 'ModelByIdVersion(id: $id, index: $index, name: $name, baseModel: $baseModel, baseModelType: $baseModelType, publishedAt: $publishedAt, availability: $availability, nsfwLevel: $nsfwLevel, description: $description, trainedWords: $trainedWords, stats: $stats, files: $files, images: $images)';
}


}

/// @nodoc
abstract mixin class $ModelByIdVersionCopyWith<$Res>  {
  factory $ModelByIdVersionCopyWith(ModelByIdVersion value, $Res Function(ModelByIdVersion) _then) = _$ModelByIdVersionCopyWithImpl;
@useResult
$Res call({
 int id, int index, String name, String baseModel, String? baseModelType, DateTime? publishedAt, String availability, int nsfwLevel, String? description, List<String> trainedWords, ModelVersionStats stats, List<ModelFile> files, List<ModelImage> images
});


$ModelVersionStatsCopyWith<$Res> get stats;

}
/// @nodoc
class _$ModelByIdVersionCopyWithImpl<$Res>
    implements $ModelByIdVersionCopyWith<$Res> {
  _$ModelByIdVersionCopyWithImpl(this._self, this._then);

  final ModelByIdVersion _self;
  final $Res Function(ModelByIdVersion) _then;

/// Create a copy of ModelByIdVersion
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
as List<ModelImage>,
  ));
}
/// Create a copy of ModelByIdVersion
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModelVersionStatsCopyWith<$Res> get stats {
  
  return $ModelVersionStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [ModelByIdVersion].
extension ModelByIdVersionPatterns on ModelByIdVersion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModelByIdVersion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModelByIdVersion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModelByIdVersion value)  $default,){
final _that = this;
switch (_that) {
case _ModelByIdVersion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModelByIdVersion value)?  $default,){
final _that = this;
switch (_that) {
case _ModelByIdVersion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int index,  String name,  String baseModel,  String? baseModelType,  DateTime? publishedAt,  String availability,  int nsfwLevel,  String? description,  List<String> trainedWords,  ModelVersionStats stats,  List<ModelFile> files,  List<ModelImage> images)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModelByIdVersion() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int index,  String name,  String baseModel,  String? baseModelType,  DateTime? publishedAt,  String availability,  int nsfwLevel,  String? description,  List<String> trainedWords,  ModelVersionStats stats,  List<ModelFile> files,  List<ModelImage> images)  $default,) {final _that = this;
switch (_that) {
case _ModelByIdVersion():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int index,  String name,  String baseModel,  String? baseModelType,  DateTime? publishedAt,  String availability,  int nsfwLevel,  String? description,  List<String> trainedWords,  ModelVersionStats stats,  List<ModelFile> files,  List<ModelImage> images)?  $default,) {final _that = this;
switch (_that) {
case _ModelByIdVersion() when $default != null:
return $default(_that.id,_that.index,_that.name,_that.baseModel,_that.baseModelType,_that.publishedAt,_that.availability,_that.nsfwLevel,_that.description,_that.trainedWords,_that.stats,_that.files,_that.images);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModelByIdVersion implements ModelByIdVersion {
  const _ModelByIdVersion({required this.id, required this.index, required this.name, required this.baseModel, this.baseModelType, this.publishedAt, this.availability = 'Public', required this.nsfwLevel, this.description, final  List<String> trainedWords = const [], this.stats = const ModelVersionStats(), final  List<ModelFile> files = const [], final  List<ModelImage> images = const []}): _trainedWords = trainedWords,_files = files,_images = images;
  factory _ModelByIdVersion.fromJson(Map<String, dynamic> json) => _$ModelByIdVersionFromJson(json);

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

 final  List<ModelImage> _images;
@override@JsonKey() List<ModelImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}


/// Create a copy of ModelByIdVersion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelByIdVersionCopyWith<_ModelByIdVersion> get copyWith => __$ModelByIdVersionCopyWithImpl<_ModelByIdVersion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModelByIdVersionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModelByIdVersion&&(identical(other.id, id) || other.id == id)&&(identical(other.index, index) || other.index == index)&&(identical(other.name, name) || other.name == name)&&(identical(other.baseModel, baseModel) || other.baseModel == baseModel)&&(identical(other.baseModelType, baseModelType) || other.baseModelType == baseModelType)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.nsfwLevel, nsfwLevel) || other.nsfwLevel == nsfwLevel)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._trainedWords, _trainedWords)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other._files, _files)&&const DeepCollectionEquality().equals(other._images, _images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,index,name,baseModel,baseModelType,publishedAt,availability,nsfwLevel,description,const DeepCollectionEquality().hash(_trainedWords),stats,const DeepCollectionEquality().hash(_files),const DeepCollectionEquality().hash(_images));

@override
String toString() {
  return 'ModelByIdVersion(id: $id, index: $index, name: $name, baseModel: $baseModel, baseModelType: $baseModelType, publishedAt: $publishedAt, availability: $availability, nsfwLevel: $nsfwLevel, description: $description, trainedWords: $trainedWords, stats: $stats, files: $files, images: $images)';
}


}

/// @nodoc
abstract mixin class _$ModelByIdVersionCopyWith<$Res> implements $ModelByIdVersionCopyWith<$Res> {
  factory _$ModelByIdVersionCopyWith(_ModelByIdVersion value, $Res Function(_ModelByIdVersion) _then) = __$ModelByIdVersionCopyWithImpl;
@override @useResult
$Res call({
 int id, int index, String name, String baseModel, String? baseModelType, DateTime? publishedAt, String availability, int nsfwLevel, String? description, List<String> trainedWords, ModelVersionStats stats, List<ModelFile> files, List<ModelImage> images
});


@override $ModelVersionStatsCopyWith<$Res> get stats;

}
/// @nodoc
class __$ModelByIdVersionCopyWithImpl<$Res>
    implements _$ModelByIdVersionCopyWith<$Res> {
  __$ModelByIdVersionCopyWithImpl(this._self, this._then);

  final _ModelByIdVersion _self;
  final $Res Function(_ModelByIdVersion) _then;

/// Create a copy of ModelByIdVersion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? index = null,Object? name = null,Object? baseModel = null,Object? baseModelType = freezed,Object? publishedAt = freezed,Object? availability = null,Object? nsfwLevel = null,Object? description = freezed,Object? trainedWords = null,Object? stats = null,Object? files = null,Object? images = null,}) {
  return _then(_ModelByIdVersion(
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
as List<ModelImage>,
  ));
}

/// Create a copy of ModelByIdVersion
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
mixin _$ModelById {

 int get id; String get name; String? get description; String get type; bool get poi; bool get nsfw; int get nsfwLevel; Creator? get creator; ModelStats get stats; List<String> get tags; List<ModelByIdVersion> get modelVersions;
/// Create a copy of ModelById
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelByIdCopyWith<ModelById> get copyWith => _$ModelByIdCopyWithImpl<ModelById>(this as ModelById, _$identity);

  /// Serializes this ModelById to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModelById&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.poi, poi) || other.poi == poi)&&(identical(other.nsfw, nsfw) || other.nsfw == nsfw)&&(identical(other.nsfwLevel, nsfwLevel) || other.nsfwLevel == nsfwLevel)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.modelVersions, modelVersions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,type,poi,nsfw,nsfwLevel,creator,stats,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(modelVersions));

@override
String toString() {
  return 'ModelById(id: $id, name: $name, description: $description, type: $type, poi: $poi, nsfw: $nsfw, nsfwLevel: $nsfwLevel, creator: $creator, stats: $stats, tags: $tags, modelVersions: $modelVersions)';
}


}

/// @nodoc
abstract mixin class $ModelByIdCopyWith<$Res>  {
  factory $ModelByIdCopyWith(ModelById value, $Res Function(ModelById) _then) = _$ModelByIdCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? description, String type, bool poi, bool nsfw, int nsfwLevel, Creator? creator, ModelStats stats, List<String> tags, List<ModelByIdVersion> modelVersions
});


$CreatorCopyWith<$Res>? get creator;$ModelStatsCopyWith<$Res> get stats;

}
/// @nodoc
class _$ModelByIdCopyWithImpl<$Res>
    implements $ModelByIdCopyWith<$Res> {
  _$ModelByIdCopyWithImpl(this._self, this._then);

  final ModelById _self;
  final $Res Function(ModelById) _then;

/// Create a copy of ModelById
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
as List<ModelByIdVersion>,
  ));
}
/// Create a copy of ModelById
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
}/// Create a copy of ModelById
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModelStatsCopyWith<$Res> get stats {
  
  return $ModelStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [ModelById].
extension ModelByIdPatterns on ModelById {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModelById value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModelById() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModelById value)  $default,){
final _that = this;
switch (_that) {
case _ModelById():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModelById value)?  $default,){
final _that = this;
switch (_that) {
case _ModelById() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? description,  String type,  bool poi,  bool nsfw,  int nsfwLevel,  Creator? creator,  ModelStats stats,  List<String> tags,  List<ModelByIdVersion> modelVersions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModelById() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? description,  String type,  bool poi,  bool nsfw,  int nsfwLevel,  Creator? creator,  ModelStats stats,  List<String> tags,  List<ModelByIdVersion> modelVersions)  $default,) {final _that = this;
switch (_that) {
case _ModelById():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? description,  String type,  bool poi,  bool nsfw,  int nsfwLevel,  Creator? creator,  ModelStats stats,  List<String> tags,  List<ModelByIdVersion> modelVersions)?  $default,) {final _that = this;
switch (_that) {
case _ModelById() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.type,_that.poi,_that.nsfw,_that.nsfwLevel,_that.creator,_that.stats,_that.tags,_that.modelVersions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModelById implements ModelById {
  const _ModelById({required this.id, required this.name, this.description, this.type = 'Other', this.poi = false, this.nsfw = false, required this.nsfwLevel, this.creator, this.stats = const ModelStats(), final  List<String> tags = const [], final  List<ModelByIdVersion> modelVersions = const []}): _tags = tags,_modelVersions = modelVersions;
  factory _ModelById.fromJson(Map<String, dynamic> json) => _$ModelByIdFromJson(json);

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

 final  List<ModelByIdVersion> _modelVersions;
@override@JsonKey() List<ModelByIdVersion> get modelVersions {
  if (_modelVersions is EqualUnmodifiableListView) return _modelVersions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_modelVersions);
}


/// Create a copy of ModelById
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelByIdCopyWith<_ModelById> get copyWith => __$ModelByIdCopyWithImpl<_ModelById>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModelByIdToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModelById&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.poi, poi) || other.poi == poi)&&(identical(other.nsfw, nsfw) || other.nsfw == nsfw)&&(identical(other.nsfwLevel, nsfwLevel) || other.nsfwLevel == nsfwLevel)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._modelVersions, _modelVersions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,type,poi,nsfw,nsfwLevel,creator,stats,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_modelVersions));

@override
String toString() {
  return 'ModelById(id: $id, name: $name, description: $description, type: $type, poi: $poi, nsfw: $nsfw, nsfwLevel: $nsfwLevel, creator: $creator, stats: $stats, tags: $tags, modelVersions: $modelVersions)';
}


}

/// @nodoc
abstract mixin class _$ModelByIdCopyWith<$Res> implements $ModelByIdCopyWith<$Res> {
  factory _$ModelByIdCopyWith(_ModelById value, $Res Function(_ModelById) _then) = __$ModelByIdCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? description, String type, bool poi, bool nsfw, int nsfwLevel, Creator? creator, ModelStats stats, List<String> tags, List<ModelByIdVersion> modelVersions
});


@override $CreatorCopyWith<$Res>? get creator;@override $ModelStatsCopyWith<$Res> get stats;

}
/// @nodoc
class __$ModelByIdCopyWithImpl<$Res>
    implements _$ModelByIdCopyWith<$Res> {
  __$ModelByIdCopyWithImpl(this._self, this._then);

  final _ModelById _self;
  final $Res Function(_ModelById) _then;

/// Create a copy of ModelById
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? type = null,Object? poi = null,Object? nsfw = null,Object? nsfwLevel = null,Object? creator = freezed,Object? stats = null,Object? tags = null,Object? modelVersions = null,}) {
  return _then(_ModelById(
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
as List<ModelByIdVersion>,
  ));
}

/// Create a copy of ModelById
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
}/// Create a copy of ModelById
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ModelStatsCopyWith<$Res> get stats {
  
  return $ModelStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}

// dart format on
