// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shared.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FileHashes {

 String? get sha256; String? get crc32; String? get blake3; String? get autoV3; String? get autoV2; String? get autoV1;
/// Create a copy of FileHashes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileHashesCopyWith<FileHashes> get copyWith => _$FileHashesCopyWithImpl<FileHashes>(this as FileHashes, _$identity);

  /// Serializes this FileHashes to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileHashes&&(identical(other.sha256, sha256) || other.sha256 == sha256)&&(identical(other.crc32, crc32) || other.crc32 == crc32)&&(identical(other.blake3, blake3) || other.blake3 == blake3)&&(identical(other.autoV3, autoV3) || other.autoV3 == autoV3)&&(identical(other.autoV2, autoV2) || other.autoV2 == autoV2)&&(identical(other.autoV1, autoV1) || other.autoV1 == autoV1));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sha256,crc32,blake3,autoV3,autoV2,autoV1);

@override
String toString() {
  return 'FileHashes(sha256: $sha256, crc32: $crc32, blake3: $blake3, autoV3: $autoV3, autoV2: $autoV2, autoV1: $autoV1)';
}


}

/// @nodoc
abstract mixin class $FileHashesCopyWith<$Res>  {
  factory $FileHashesCopyWith(FileHashes value, $Res Function(FileHashes) _then) = _$FileHashesCopyWithImpl;
@useResult
$Res call({
 String? sha256, String? crc32, String? blake3, String? autoV3, String? autoV2, String? autoV1
});




}
/// @nodoc
class _$FileHashesCopyWithImpl<$Res>
    implements $FileHashesCopyWith<$Res> {
  _$FileHashesCopyWithImpl(this._self, this._then);

  final FileHashes _self;
  final $Res Function(FileHashes) _then;

/// Create a copy of FileHashes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sha256 = freezed,Object? crc32 = freezed,Object? blake3 = freezed,Object? autoV3 = freezed,Object? autoV2 = freezed,Object? autoV1 = freezed,}) {
  return _then(_self.copyWith(
sha256: freezed == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String?,crc32: freezed == crc32 ? _self.crc32 : crc32 // ignore: cast_nullable_to_non_nullable
as String?,blake3: freezed == blake3 ? _self.blake3 : blake3 // ignore: cast_nullable_to_non_nullable
as String?,autoV3: freezed == autoV3 ? _self.autoV3 : autoV3 // ignore: cast_nullable_to_non_nullable
as String?,autoV2: freezed == autoV2 ? _self.autoV2 : autoV2 // ignore: cast_nullable_to_non_nullable
as String?,autoV1: freezed == autoV1 ? _self.autoV1 : autoV1 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FileHashes].
extension FileHashesPatterns on FileHashes {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileHashes value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileHashes() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileHashes value)  $default,){
final _that = this;
switch (_that) {
case _FileHashes():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileHashes value)?  $default,){
final _that = this;
switch (_that) {
case _FileHashes() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? sha256,  String? crc32,  String? blake3,  String? autoV3,  String? autoV2,  String? autoV1)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileHashes() when $default != null:
return $default(_that.sha256,_that.crc32,_that.blake3,_that.autoV3,_that.autoV2,_that.autoV1);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? sha256,  String? crc32,  String? blake3,  String? autoV3,  String? autoV2,  String? autoV1)  $default,) {final _that = this;
switch (_that) {
case _FileHashes():
return $default(_that.sha256,_that.crc32,_that.blake3,_that.autoV3,_that.autoV2,_that.autoV1);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? sha256,  String? crc32,  String? blake3,  String? autoV3,  String? autoV2,  String? autoV1)?  $default,) {final _that = this;
switch (_that) {
case _FileHashes() when $default != null:
return $default(_that.sha256,_that.crc32,_that.blake3,_that.autoV3,_that.autoV2,_that.autoV1);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FileHashes implements FileHashes {
  const _FileHashes({this.sha256, this.crc32, this.blake3, this.autoV3, this.autoV2, this.autoV1});
  factory _FileHashes.fromJson(Map<String, dynamic> json) => _$FileHashesFromJson(json);

@override final  String? sha256;
@override final  String? crc32;
@override final  String? blake3;
@override final  String? autoV3;
@override final  String? autoV2;
@override final  String? autoV1;

/// Create a copy of FileHashes
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileHashesCopyWith<_FileHashes> get copyWith => __$FileHashesCopyWithImpl<_FileHashes>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FileHashesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileHashes&&(identical(other.sha256, sha256) || other.sha256 == sha256)&&(identical(other.crc32, crc32) || other.crc32 == crc32)&&(identical(other.blake3, blake3) || other.blake3 == blake3)&&(identical(other.autoV3, autoV3) || other.autoV3 == autoV3)&&(identical(other.autoV2, autoV2) || other.autoV2 == autoV2)&&(identical(other.autoV1, autoV1) || other.autoV1 == autoV1));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sha256,crc32,blake3,autoV3,autoV2,autoV1);

@override
String toString() {
  return 'FileHashes(sha256: $sha256, crc32: $crc32, blake3: $blake3, autoV3: $autoV3, autoV2: $autoV2, autoV1: $autoV1)';
}


}

/// @nodoc
abstract mixin class _$FileHashesCopyWith<$Res> implements $FileHashesCopyWith<$Res> {
  factory _$FileHashesCopyWith(_FileHashes value, $Res Function(_FileHashes) _then) = __$FileHashesCopyWithImpl;
@override @useResult
$Res call({
 String? sha256, String? crc32, String? blake3, String? autoV3, String? autoV2, String? autoV1
});




}
/// @nodoc
class __$FileHashesCopyWithImpl<$Res>
    implements _$FileHashesCopyWith<$Res> {
  __$FileHashesCopyWithImpl(this._self, this._then);

  final _FileHashes _self;
  final $Res Function(_FileHashes) _then;

/// Create a copy of FileHashes
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sha256 = freezed,Object? crc32 = freezed,Object? blake3 = freezed,Object? autoV3 = freezed,Object? autoV2 = freezed,Object? autoV1 = freezed,}) {
  return _then(_FileHashes(
sha256: freezed == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String?,crc32: freezed == crc32 ? _self.crc32 : crc32 // ignore: cast_nullable_to_non_nullable
as String?,blake3: freezed == blake3 ? _self.blake3 : blake3 // ignore: cast_nullable_to_non_nullable
as String?,autoV3: freezed == autoV3 ? _self.autoV3 : autoV3 // ignore: cast_nullable_to_non_nullable
as String?,autoV2: freezed == autoV2 ? _self.autoV2 : autoV2 // ignore: cast_nullable_to_non_nullable
as String?,autoV1: freezed == autoV1 ? _self.autoV1 : autoV1 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FileMetadata {

 String? get fp; String? get size; String? get format;
/// Create a copy of FileMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileMetadataCopyWith<FileMetadata> get copyWith => _$FileMetadataCopyWithImpl<FileMetadata>(this as FileMetadata, _$identity);

  /// Serializes this FileMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileMetadata&&(identical(other.fp, fp) || other.fp == fp)&&(identical(other.size, size) || other.size == size)&&(identical(other.format, format) || other.format == format));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fp,size,format);

@override
String toString() {
  return 'FileMetadata(fp: $fp, size: $size, format: $format)';
}


}

/// @nodoc
abstract mixin class $FileMetadataCopyWith<$Res>  {
  factory $FileMetadataCopyWith(FileMetadata value, $Res Function(FileMetadata) _then) = _$FileMetadataCopyWithImpl;
@useResult
$Res call({
 String? fp, String? size, String? format
});




}
/// @nodoc
class _$FileMetadataCopyWithImpl<$Res>
    implements $FileMetadataCopyWith<$Res> {
  _$FileMetadataCopyWithImpl(this._self, this._then);

  final FileMetadata _self;
  final $Res Function(FileMetadata) _then;

/// Create a copy of FileMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fp = freezed,Object? size = freezed,Object? format = freezed,}) {
  return _then(_self.copyWith(
fp: freezed == fp ? _self.fp : fp // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,format: freezed == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FileMetadata].
extension FileMetadataPatterns on FileMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileMetadata value)  $default,){
final _that = this;
switch (_that) {
case _FileMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _FileMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? fp,  String? size,  String? format)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileMetadata() when $default != null:
return $default(_that.fp,_that.size,_that.format);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? fp,  String? size,  String? format)  $default,) {final _that = this;
switch (_that) {
case _FileMetadata():
return $default(_that.fp,_that.size,_that.format);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? fp,  String? size,  String? format)?  $default,) {final _that = this;
switch (_that) {
case _FileMetadata() when $default != null:
return $default(_that.fp,_that.size,_that.format);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FileMetadata implements FileMetadata {
  const _FileMetadata({this.fp, this.size, this.format});
  factory _FileMetadata.fromJson(Map<String, dynamic> json) => _$FileMetadataFromJson(json);

@override final  String? fp;
@override final  String? size;
@override final  String? format;

/// Create a copy of FileMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileMetadataCopyWith<_FileMetadata> get copyWith => __$FileMetadataCopyWithImpl<_FileMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FileMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileMetadata&&(identical(other.fp, fp) || other.fp == fp)&&(identical(other.size, size) || other.size == size)&&(identical(other.format, format) || other.format == format));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fp,size,format);

@override
String toString() {
  return 'FileMetadata(fp: $fp, size: $size, format: $format)';
}


}

/// @nodoc
abstract mixin class _$FileMetadataCopyWith<$Res> implements $FileMetadataCopyWith<$Res> {
  factory _$FileMetadataCopyWith(_FileMetadata value, $Res Function(_FileMetadata) _then) = __$FileMetadataCopyWithImpl;
@override @useResult
$Res call({
 String? fp, String? size, String? format
});




}
/// @nodoc
class __$FileMetadataCopyWithImpl<$Res>
    implements _$FileMetadataCopyWith<$Res> {
  __$FileMetadataCopyWithImpl(this._self, this._then);

  final _FileMetadata _self;
  final $Res Function(_FileMetadata) _then;

/// Create a copy of FileMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fp = freezed,Object? size = freezed,Object? format = freezed,}) {
  return _then(_FileMetadata(
fp: freezed == fp ? _self.fp : fp // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,format: freezed == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ModelFile {

 int get id; double get sizeKB; String get name; String get type; FileMetadata get metadata; DateTime? get scannedAt; FileHashes? get hashes; String get downloadUrl;
/// Create a copy of ModelFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelFileCopyWith<ModelFile> get copyWith => _$ModelFileCopyWithImpl<ModelFile>(this as ModelFile, _$identity);

  /// Serializes this ModelFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModelFile&&(identical(other.id, id) || other.id == id)&&(identical(other.sizeKB, sizeKB) || other.sizeKB == sizeKB)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.scannedAt, scannedAt) || other.scannedAt == scannedAt)&&(identical(other.hashes, hashes) || other.hashes == hashes)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sizeKB,name,type,metadata,scannedAt,hashes,downloadUrl);

@override
String toString() {
  return 'ModelFile(id: $id, sizeKB: $sizeKB, name: $name, type: $type, metadata: $metadata, scannedAt: $scannedAt, hashes: $hashes, downloadUrl: $downloadUrl)';
}


}

/// @nodoc
abstract mixin class $ModelFileCopyWith<$Res>  {
  factory $ModelFileCopyWith(ModelFile value, $Res Function(ModelFile) _then) = _$ModelFileCopyWithImpl;
@useResult
$Res call({
 int id, double sizeKB, String name, String type, FileMetadata metadata, DateTime? scannedAt, FileHashes? hashes, String downloadUrl
});


$FileMetadataCopyWith<$Res> get metadata;$FileHashesCopyWith<$Res>? get hashes;

}
/// @nodoc
class _$ModelFileCopyWithImpl<$Res>
    implements $ModelFileCopyWith<$Res> {
  _$ModelFileCopyWithImpl(this._self, this._then);

  final ModelFile _self;
  final $Res Function(ModelFile) _then;

/// Create a copy of ModelFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sizeKB = null,Object? name = null,Object? type = null,Object? metadata = null,Object? scannedAt = freezed,Object? hashes = freezed,Object? downloadUrl = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,sizeKB: null == sizeKB ? _self.sizeKB : sizeKB // ignore: cast_nullable_to_non_nullable
as double,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as FileMetadata,scannedAt: freezed == scannedAt ? _self.scannedAt : scannedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hashes: freezed == hashes ? _self.hashes : hashes // ignore: cast_nullable_to_non_nullable
as FileHashes?,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of ModelFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileMetadataCopyWith<$Res> get metadata {
  
  return $FileMetadataCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}/// Create a copy of ModelFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileHashesCopyWith<$Res>? get hashes {
    if (_self.hashes == null) {
    return null;
  }

  return $FileHashesCopyWith<$Res>(_self.hashes!, (value) {
    return _then(_self.copyWith(hashes: value));
  });
}
}


/// Adds pattern-matching-related methods to [ModelFile].
extension ModelFilePatterns on ModelFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModelFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModelFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModelFile value)  $default,){
final _that = this;
switch (_that) {
case _ModelFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModelFile value)?  $default,){
final _that = this;
switch (_that) {
case _ModelFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  double sizeKB,  String name,  String type,  FileMetadata metadata,  DateTime? scannedAt,  FileHashes? hashes,  String downloadUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModelFile() when $default != null:
return $default(_that.id,_that.sizeKB,_that.name,_that.type,_that.metadata,_that.scannedAt,_that.hashes,_that.downloadUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  double sizeKB,  String name,  String type,  FileMetadata metadata,  DateTime? scannedAt,  FileHashes? hashes,  String downloadUrl)  $default,) {final _that = this;
switch (_that) {
case _ModelFile():
return $default(_that.id,_that.sizeKB,_that.name,_that.type,_that.metadata,_that.scannedAt,_that.hashes,_that.downloadUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  double sizeKB,  String name,  String type,  FileMetadata metadata,  DateTime? scannedAt,  FileHashes? hashes,  String downloadUrl)?  $default,) {final _that = this;
switch (_that) {
case _ModelFile() when $default != null:
return $default(_that.id,_that.sizeKB,_that.name,_that.type,_that.metadata,_that.scannedAt,_that.hashes,_that.downloadUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModelFile implements ModelFile {
  const _ModelFile({required this.id, required this.sizeKB, required this.name, required this.type, this.metadata = const FileMetadata(), this.scannedAt, this.hashes, required this.downloadUrl});
  factory _ModelFile.fromJson(Map<String, dynamic> json) => _$ModelFileFromJson(json);

@override final  int id;
@override final  double sizeKB;
@override final  String name;
@override final  String type;
@override@JsonKey() final  FileMetadata metadata;
@override final  DateTime? scannedAt;
@override final  FileHashes? hashes;
@override final  String downloadUrl;

/// Create a copy of ModelFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelFileCopyWith<_ModelFile> get copyWith => __$ModelFileCopyWithImpl<_ModelFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModelFileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModelFile&&(identical(other.id, id) || other.id == id)&&(identical(other.sizeKB, sizeKB) || other.sizeKB == sizeKB)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.scannedAt, scannedAt) || other.scannedAt == scannedAt)&&(identical(other.hashes, hashes) || other.hashes == hashes)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sizeKB,name,type,metadata,scannedAt,hashes,downloadUrl);

@override
String toString() {
  return 'ModelFile(id: $id, sizeKB: $sizeKB, name: $name, type: $type, metadata: $metadata, scannedAt: $scannedAt, hashes: $hashes, downloadUrl: $downloadUrl)';
}


}

/// @nodoc
abstract mixin class _$ModelFileCopyWith<$Res> implements $ModelFileCopyWith<$Res> {
  factory _$ModelFileCopyWith(_ModelFile value, $Res Function(_ModelFile) _then) = __$ModelFileCopyWithImpl;
@override @useResult
$Res call({
 int id, double sizeKB, String name, String type, FileMetadata metadata, DateTime? scannedAt, FileHashes? hashes, String downloadUrl
});


@override $FileMetadataCopyWith<$Res> get metadata;@override $FileHashesCopyWith<$Res>? get hashes;

}
/// @nodoc
class __$ModelFileCopyWithImpl<$Res>
    implements _$ModelFileCopyWith<$Res> {
  __$ModelFileCopyWithImpl(this._self, this._then);

  final _ModelFile _self;
  final $Res Function(_ModelFile) _then;

/// Create a copy of ModelFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sizeKB = null,Object? name = null,Object? type = null,Object? metadata = null,Object? scannedAt = freezed,Object? hashes = freezed,Object? downloadUrl = null,}) {
  return _then(_ModelFile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,sizeKB: null == sizeKB ? _self.sizeKB : sizeKB // ignore: cast_nullable_to_non_nullable
as double,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as FileMetadata,scannedAt: freezed == scannedAt ? _self.scannedAt : scannedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hashes: freezed == hashes ? _self.hashes : hashes // ignore: cast_nullable_to_non_nullable
as FileHashes?,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of ModelFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileMetadataCopyWith<$Res> get metadata {
  
  return $FileMetadataCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}/// Create a copy of ModelFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FileHashesCopyWith<$Res>? get hashes {
    if (_self.hashes == null) {
    return null;
  }

  return $FileHashesCopyWith<$Res>(_self.hashes!, (value) {
    return _then(_self.copyWith(hashes: value));
  });
}
}


/// @nodoc
mixin _$ModelImage {

 String get url; int get nsfwLevel; int get width; int get height; String get hash; String get type;
/// Create a copy of ModelImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelImageCopyWith<ModelImage> get copyWith => _$ModelImageCopyWithImpl<ModelImage>(this as ModelImage, _$identity);

  /// Serializes this ModelImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModelImage&&(identical(other.url, url) || other.url == url)&&(identical(other.nsfwLevel, nsfwLevel) || other.nsfwLevel == nsfwLevel)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,nsfwLevel,width,height,hash,type);

@override
String toString() {
  return 'ModelImage(url: $url, nsfwLevel: $nsfwLevel, width: $width, height: $height, hash: $hash, type: $type)';
}


}

/// @nodoc
abstract mixin class $ModelImageCopyWith<$Res>  {
  factory $ModelImageCopyWith(ModelImage value, $Res Function(ModelImage) _then) = _$ModelImageCopyWithImpl;
@useResult
$Res call({
 String url, int nsfwLevel, int width, int height, String hash, String type
});




}
/// @nodoc
class _$ModelImageCopyWithImpl<$Res>
    implements $ModelImageCopyWith<$Res> {
  _$ModelImageCopyWithImpl(this._self, this._then);

  final ModelImage _self;
  final $Res Function(ModelImage) _then;

/// Create a copy of ModelImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? nsfwLevel = null,Object? width = null,Object? height = null,Object? hash = null,Object? type = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,nsfwLevel: null == nsfwLevel ? _self.nsfwLevel : nsfwLevel // ignore: cast_nullable_to_non_nullable
as int,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ModelImage].
extension ModelImagePatterns on ModelImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModelImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModelImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModelImage value)  $default,){
final _that = this;
switch (_that) {
case _ModelImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModelImage value)?  $default,){
final _that = this;
switch (_that) {
case _ModelImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  int nsfwLevel,  int width,  int height,  String hash,  String type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModelImage() when $default != null:
return $default(_that.url,_that.nsfwLevel,_that.width,_that.height,_that.hash,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  int nsfwLevel,  int width,  int height,  String hash,  String type)  $default,) {final _that = this;
switch (_that) {
case _ModelImage():
return $default(_that.url,_that.nsfwLevel,_that.width,_that.height,_that.hash,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  int nsfwLevel,  int width,  int height,  String hash,  String type)?  $default,) {final _that = this;
switch (_that) {
case _ModelImage() when $default != null:
return $default(_that.url,_that.nsfwLevel,_that.width,_that.height,_that.hash,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModelImage implements ModelImage {
  const _ModelImage({required this.url, required this.nsfwLevel, required this.width, required this.height, required this.hash, required this.type});
  factory _ModelImage.fromJson(Map<String, dynamic> json) => _$ModelImageFromJson(json);

@override final  String url;
@override final  int nsfwLevel;
@override final  int width;
@override final  int height;
@override final  String hash;
@override final  String type;

/// Create a copy of ModelImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelImageCopyWith<_ModelImage> get copyWith => __$ModelImageCopyWithImpl<_ModelImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModelImageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModelImage&&(identical(other.url, url) || other.url == url)&&(identical(other.nsfwLevel, nsfwLevel) || other.nsfwLevel == nsfwLevel)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,nsfwLevel,width,height,hash,type);

@override
String toString() {
  return 'ModelImage(url: $url, nsfwLevel: $nsfwLevel, width: $width, height: $height, hash: $hash, type: $type)';
}


}

/// @nodoc
abstract mixin class _$ModelImageCopyWith<$Res> implements $ModelImageCopyWith<$Res> {
  factory _$ModelImageCopyWith(_ModelImage value, $Res Function(_ModelImage) _then) = __$ModelImageCopyWithImpl;
@override @useResult
$Res call({
 String url, int nsfwLevel, int width, int height, String hash, String type
});




}
/// @nodoc
class __$ModelImageCopyWithImpl<$Res>
    implements _$ModelImageCopyWith<$Res> {
  __$ModelImageCopyWithImpl(this._self, this._then);

  final _ModelImage _self;
  final $Res Function(_ModelImage) _then;

/// Create a copy of ModelImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? nsfwLevel = null,Object? width = null,Object? height = null,Object? hash = null,Object? type = null,}) {
  return _then(_ModelImage(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,nsfwLevel: null == nsfwLevel ? _self.nsfwLevel : nsfwLevel // ignore: cast_nullable_to_non_nullable
as int,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ModelImageWithId {

 int get id; String get url; int get nsfwLevel; int get width; int get height; String get hash; String get type;
/// Create a copy of ModelImageWithId
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelImageWithIdCopyWith<ModelImageWithId> get copyWith => _$ModelImageWithIdCopyWithImpl<ModelImageWithId>(this as ModelImageWithId, _$identity);

  /// Serializes this ModelImageWithId to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModelImageWithId&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.nsfwLevel, nsfwLevel) || other.nsfwLevel == nsfwLevel)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,nsfwLevel,width,height,hash,type);

@override
String toString() {
  return 'ModelImageWithId(id: $id, url: $url, nsfwLevel: $nsfwLevel, width: $width, height: $height, hash: $hash, type: $type)';
}


}

/// @nodoc
abstract mixin class $ModelImageWithIdCopyWith<$Res>  {
  factory $ModelImageWithIdCopyWith(ModelImageWithId value, $Res Function(ModelImageWithId) _then) = _$ModelImageWithIdCopyWithImpl;
@useResult
$Res call({
 int id, String url, int nsfwLevel, int width, int height, String hash, String type
});




}
/// @nodoc
class _$ModelImageWithIdCopyWithImpl<$Res>
    implements $ModelImageWithIdCopyWith<$Res> {
  _$ModelImageWithIdCopyWithImpl(this._self, this._then);

  final ModelImageWithId _self;
  final $Res Function(ModelImageWithId) _then;

/// Create a copy of ModelImageWithId
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? nsfwLevel = null,Object? width = null,Object? height = null,Object? hash = null,Object? type = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,nsfwLevel: null == nsfwLevel ? _self.nsfwLevel : nsfwLevel // ignore: cast_nullable_to_non_nullable
as int,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ModelImageWithId].
extension ModelImageWithIdPatterns on ModelImageWithId {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModelImageWithId value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModelImageWithId() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModelImageWithId value)  $default,){
final _that = this;
switch (_that) {
case _ModelImageWithId():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModelImageWithId value)?  $default,){
final _that = this;
switch (_that) {
case _ModelImageWithId() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String url,  int nsfwLevel,  int width,  int height,  String hash,  String type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModelImageWithId() when $default != null:
return $default(_that.id,_that.url,_that.nsfwLevel,_that.width,_that.height,_that.hash,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String url,  int nsfwLevel,  int width,  int height,  String hash,  String type)  $default,) {final _that = this;
switch (_that) {
case _ModelImageWithId():
return $default(_that.id,_that.url,_that.nsfwLevel,_that.width,_that.height,_that.hash,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String url,  int nsfwLevel,  int width,  int height,  String hash,  String type)?  $default,) {final _that = this;
switch (_that) {
case _ModelImageWithId() when $default != null:
return $default(_that.id,_that.url,_that.nsfwLevel,_that.width,_that.height,_that.hash,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModelImageWithId implements ModelImageWithId {
  const _ModelImageWithId({required this.id, required this.url, required this.nsfwLevel, required this.width, required this.height, required this.hash, required this.type});
  factory _ModelImageWithId.fromJson(Map<String, dynamic> json) => _$ModelImageWithIdFromJson(json);

@override final  int id;
@override final  String url;
@override final  int nsfwLevel;
@override final  int width;
@override final  int height;
@override final  String hash;
@override final  String type;

/// Create a copy of ModelImageWithId
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelImageWithIdCopyWith<_ModelImageWithId> get copyWith => __$ModelImageWithIdCopyWithImpl<_ModelImageWithId>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModelImageWithIdToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModelImageWithId&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.nsfwLevel, nsfwLevel) || other.nsfwLevel == nsfwLevel)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,nsfwLevel,width,height,hash,type);

@override
String toString() {
  return 'ModelImageWithId(id: $id, url: $url, nsfwLevel: $nsfwLevel, width: $width, height: $height, hash: $hash, type: $type)';
}


}

/// @nodoc
abstract mixin class _$ModelImageWithIdCopyWith<$Res> implements $ModelImageWithIdCopyWith<$Res> {
  factory _$ModelImageWithIdCopyWith(_ModelImageWithId value, $Res Function(_ModelImageWithId) _then) = __$ModelImageWithIdCopyWithImpl;
@override @useResult
$Res call({
 int id, String url, int nsfwLevel, int width, int height, String hash, String type
});




}
/// @nodoc
class __$ModelImageWithIdCopyWithImpl<$Res>
    implements _$ModelImageWithIdCopyWith<$Res> {
  __$ModelImageWithIdCopyWithImpl(this._self, this._then);

  final _ModelImageWithId _self;
  final $Res Function(_ModelImageWithId) _then;

/// Create a copy of ModelImageWithId
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? nsfwLevel = null,Object? width = null,Object? height = null,Object? hash = null,Object? type = null,}) {
  return _then(_ModelImageWithId(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,nsfwLevel: null == nsfwLevel ? _self.nsfwLevel : nsfwLevel // ignore: cast_nullable_to_non_nullable
as int,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ModelVersionStats {

 int get downloadCount; int? get ratingCount; double? get rating; int get thumbsUpCount; int get thumbsDownCount;
/// Create a copy of ModelVersionStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelVersionStatsCopyWith<ModelVersionStats> get copyWith => _$ModelVersionStatsCopyWithImpl<ModelVersionStats>(this as ModelVersionStats, _$identity);

  /// Serializes this ModelVersionStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModelVersionStats&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.thumbsUpCount, thumbsUpCount) || other.thumbsUpCount == thumbsUpCount)&&(identical(other.thumbsDownCount, thumbsDownCount) || other.thumbsDownCount == thumbsDownCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,downloadCount,ratingCount,rating,thumbsUpCount,thumbsDownCount);

@override
String toString() {
  return 'ModelVersionStats(downloadCount: $downloadCount, ratingCount: $ratingCount, rating: $rating, thumbsUpCount: $thumbsUpCount, thumbsDownCount: $thumbsDownCount)';
}


}

/// @nodoc
abstract mixin class $ModelVersionStatsCopyWith<$Res>  {
  factory $ModelVersionStatsCopyWith(ModelVersionStats value, $Res Function(ModelVersionStats) _then) = _$ModelVersionStatsCopyWithImpl;
@useResult
$Res call({
 int downloadCount, int? ratingCount, double? rating, int thumbsUpCount, int thumbsDownCount
});




}
/// @nodoc
class _$ModelVersionStatsCopyWithImpl<$Res>
    implements $ModelVersionStatsCopyWith<$Res> {
  _$ModelVersionStatsCopyWithImpl(this._self, this._then);

  final ModelVersionStats _self;
  final $Res Function(ModelVersionStats) _then;

/// Create a copy of ModelVersionStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? downloadCount = null,Object? ratingCount = freezed,Object? rating = freezed,Object? thumbsUpCount = null,Object? thumbsDownCount = null,}) {
  return _then(_self.copyWith(
downloadCount: null == downloadCount ? _self.downloadCount : downloadCount // ignore: cast_nullable_to_non_nullable
as int,ratingCount: freezed == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,thumbsUpCount: null == thumbsUpCount ? _self.thumbsUpCount : thumbsUpCount // ignore: cast_nullable_to_non_nullable
as int,thumbsDownCount: null == thumbsDownCount ? _self.thumbsDownCount : thumbsDownCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ModelVersionStats].
extension ModelVersionStatsPatterns on ModelVersionStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModelVersionStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModelVersionStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModelVersionStats value)  $default,){
final _that = this;
switch (_that) {
case _ModelVersionStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModelVersionStats value)?  $default,){
final _that = this;
switch (_that) {
case _ModelVersionStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int downloadCount,  int? ratingCount,  double? rating,  int thumbsUpCount,  int thumbsDownCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModelVersionStats() when $default != null:
return $default(_that.downloadCount,_that.ratingCount,_that.rating,_that.thumbsUpCount,_that.thumbsDownCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int downloadCount,  int? ratingCount,  double? rating,  int thumbsUpCount,  int thumbsDownCount)  $default,) {final _that = this;
switch (_that) {
case _ModelVersionStats():
return $default(_that.downloadCount,_that.ratingCount,_that.rating,_that.thumbsUpCount,_that.thumbsDownCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int downloadCount,  int? ratingCount,  double? rating,  int thumbsUpCount,  int thumbsDownCount)?  $default,) {final _that = this;
switch (_that) {
case _ModelVersionStats() when $default != null:
return $default(_that.downloadCount,_that.ratingCount,_that.rating,_that.thumbsUpCount,_that.thumbsDownCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModelVersionStats implements ModelVersionStats {
  const _ModelVersionStats({this.downloadCount = 0, this.ratingCount, this.rating, this.thumbsUpCount = 0, this.thumbsDownCount = 0});
  factory _ModelVersionStats.fromJson(Map<String, dynamic> json) => _$ModelVersionStatsFromJson(json);

@override@JsonKey() final  int downloadCount;
@override final  int? ratingCount;
@override final  double? rating;
@override@JsonKey() final  int thumbsUpCount;
@override@JsonKey() final  int thumbsDownCount;

/// Create a copy of ModelVersionStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelVersionStatsCopyWith<_ModelVersionStats> get copyWith => __$ModelVersionStatsCopyWithImpl<_ModelVersionStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModelVersionStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModelVersionStats&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.thumbsUpCount, thumbsUpCount) || other.thumbsUpCount == thumbsUpCount)&&(identical(other.thumbsDownCount, thumbsDownCount) || other.thumbsDownCount == thumbsDownCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,downloadCount,ratingCount,rating,thumbsUpCount,thumbsDownCount);

@override
String toString() {
  return 'ModelVersionStats(downloadCount: $downloadCount, ratingCount: $ratingCount, rating: $rating, thumbsUpCount: $thumbsUpCount, thumbsDownCount: $thumbsDownCount)';
}


}

/// @nodoc
abstract mixin class _$ModelVersionStatsCopyWith<$Res> implements $ModelVersionStatsCopyWith<$Res> {
  factory _$ModelVersionStatsCopyWith(_ModelVersionStats value, $Res Function(_ModelVersionStats) _then) = __$ModelVersionStatsCopyWithImpl;
@override @useResult
$Res call({
 int downloadCount, int? ratingCount, double? rating, int thumbsUpCount, int thumbsDownCount
});




}
/// @nodoc
class __$ModelVersionStatsCopyWithImpl<$Res>
    implements _$ModelVersionStatsCopyWith<$Res> {
  __$ModelVersionStatsCopyWithImpl(this._self, this._then);

  final _ModelVersionStats _self;
  final $Res Function(_ModelVersionStats) _then;

/// Create a copy of ModelVersionStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? downloadCount = null,Object? ratingCount = freezed,Object? rating = freezed,Object? thumbsUpCount = null,Object? thumbsDownCount = null,}) {
  return _then(_ModelVersionStats(
downloadCount: null == downloadCount ? _self.downloadCount : downloadCount // ignore: cast_nullable_to_non_nullable
as int,ratingCount: freezed == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,thumbsUpCount: null == thumbsUpCount ? _self.thumbsUpCount : thumbsUpCount // ignore: cast_nullable_to_non_nullable
as int,thumbsDownCount: null == thumbsDownCount ? _self.thumbsDownCount : thumbsDownCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ModelVersionEndpointStats {

 int get downloadCount; int? get ratingCount; double? get rating; int get thumbsUpCount;
/// Create a copy of ModelVersionEndpointStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelVersionEndpointStatsCopyWith<ModelVersionEndpointStats> get copyWith => _$ModelVersionEndpointStatsCopyWithImpl<ModelVersionEndpointStats>(this as ModelVersionEndpointStats, _$identity);

  /// Serializes this ModelVersionEndpointStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModelVersionEndpointStats&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.thumbsUpCount, thumbsUpCount) || other.thumbsUpCount == thumbsUpCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,downloadCount,ratingCount,rating,thumbsUpCount);

@override
String toString() {
  return 'ModelVersionEndpointStats(downloadCount: $downloadCount, ratingCount: $ratingCount, rating: $rating, thumbsUpCount: $thumbsUpCount)';
}


}

/// @nodoc
abstract mixin class $ModelVersionEndpointStatsCopyWith<$Res>  {
  factory $ModelVersionEndpointStatsCopyWith(ModelVersionEndpointStats value, $Res Function(ModelVersionEndpointStats) _then) = _$ModelVersionEndpointStatsCopyWithImpl;
@useResult
$Res call({
 int downloadCount, int? ratingCount, double? rating, int thumbsUpCount
});




}
/// @nodoc
class _$ModelVersionEndpointStatsCopyWithImpl<$Res>
    implements $ModelVersionEndpointStatsCopyWith<$Res> {
  _$ModelVersionEndpointStatsCopyWithImpl(this._self, this._then);

  final ModelVersionEndpointStats _self;
  final $Res Function(ModelVersionEndpointStats) _then;

/// Create a copy of ModelVersionEndpointStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? downloadCount = null,Object? ratingCount = freezed,Object? rating = freezed,Object? thumbsUpCount = null,}) {
  return _then(_self.copyWith(
downloadCount: null == downloadCount ? _self.downloadCount : downloadCount // ignore: cast_nullable_to_non_nullable
as int,ratingCount: freezed == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,thumbsUpCount: null == thumbsUpCount ? _self.thumbsUpCount : thumbsUpCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ModelVersionEndpointStats].
extension ModelVersionEndpointStatsPatterns on ModelVersionEndpointStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModelVersionEndpointStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModelVersionEndpointStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModelVersionEndpointStats value)  $default,){
final _that = this;
switch (_that) {
case _ModelVersionEndpointStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModelVersionEndpointStats value)?  $default,){
final _that = this;
switch (_that) {
case _ModelVersionEndpointStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int downloadCount,  int? ratingCount,  double? rating,  int thumbsUpCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModelVersionEndpointStats() when $default != null:
return $default(_that.downloadCount,_that.ratingCount,_that.rating,_that.thumbsUpCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int downloadCount,  int? ratingCount,  double? rating,  int thumbsUpCount)  $default,) {final _that = this;
switch (_that) {
case _ModelVersionEndpointStats():
return $default(_that.downloadCount,_that.ratingCount,_that.rating,_that.thumbsUpCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int downloadCount,  int? ratingCount,  double? rating,  int thumbsUpCount)?  $default,) {final _that = this;
switch (_that) {
case _ModelVersionEndpointStats() when $default != null:
return $default(_that.downloadCount,_that.ratingCount,_that.rating,_that.thumbsUpCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModelVersionEndpointStats implements ModelVersionEndpointStats {
  const _ModelVersionEndpointStats({this.downloadCount = 0, this.ratingCount, this.rating, this.thumbsUpCount = 0});
  factory _ModelVersionEndpointStats.fromJson(Map<String, dynamic> json) => _$ModelVersionEndpointStatsFromJson(json);

@override@JsonKey() final  int downloadCount;
@override final  int? ratingCount;
@override final  double? rating;
@override@JsonKey() final  int thumbsUpCount;

/// Create a copy of ModelVersionEndpointStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelVersionEndpointStatsCopyWith<_ModelVersionEndpointStats> get copyWith => __$ModelVersionEndpointStatsCopyWithImpl<_ModelVersionEndpointStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModelVersionEndpointStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModelVersionEndpointStats&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.thumbsUpCount, thumbsUpCount) || other.thumbsUpCount == thumbsUpCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,downloadCount,ratingCount,rating,thumbsUpCount);

@override
String toString() {
  return 'ModelVersionEndpointStats(downloadCount: $downloadCount, ratingCount: $ratingCount, rating: $rating, thumbsUpCount: $thumbsUpCount)';
}


}

/// @nodoc
abstract mixin class _$ModelVersionEndpointStatsCopyWith<$Res> implements $ModelVersionEndpointStatsCopyWith<$Res> {
  factory _$ModelVersionEndpointStatsCopyWith(_ModelVersionEndpointStats value, $Res Function(_ModelVersionEndpointStats) _then) = __$ModelVersionEndpointStatsCopyWithImpl;
@override @useResult
$Res call({
 int downloadCount, int? ratingCount, double? rating, int thumbsUpCount
});




}
/// @nodoc
class __$ModelVersionEndpointStatsCopyWithImpl<$Res>
    implements _$ModelVersionEndpointStatsCopyWith<$Res> {
  __$ModelVersionEndpointStatsCopyWithImpl(this._self, this._then);

  final _ModelVersionEndpointStats _self;
  final $Res Function(_ModelVersionEndpointStats) _then;

/// Create a copy of ModelVersionEndpointStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? downloadCount = null,Object? ratingCount = freezed,Object? rating = freezed,Object? thumbsUpCount = null,}) {
  return _then(_ModelVersionEndpointStats(
downloadCount: null == downloadCount ? _self.downloadCount : downloadCount // ignore: cast_nullable_to_non_nullable
as int,ratingCount: freezed == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,thumbsUpCount: null == thumbsUpCount ? _self.thumbsUpCount : thumbsUpCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ModelStats {

 int get downloadCount; int? get favoriteCount; int get thumbsUpCount; int? get thumbsDownCount; int get commentCount; int? get ratingCount; double? get rating; int get tippedAmountCount;
/// Create a copy of ModelStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelStatsCopyWith<ModelStats> get copyWith => _$ModelStatsCopyWithImpl<ModelStats>(this as ModelStats, _$identity);

  /// Serializes this ModelStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModelStats&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.favoriteCount, favoriteCount) || other.favoriteCount == favoriteCount)&&(identical(other.thumbsUpCount, thumbsUpCount) || other.thumbsUpCount == thumbsUpCount)&&(identical(other.thumbsDownCount, thumbsDownCount) || other.thumbsDownCount == thumbsDownCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.tippedAmountCount, tippedAmountCount) || other.tippedAmountCount == tippedAmountCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,downloadCount,favoriteCount,thumbsUpCount,thumbsDownCount,commentCount,ratingCount,rating,tippedAmountCount);

@override
String toString() {
  return 'ModelStats(downloadCount: $downloadCount, favoriteCount: $favoriteCount, thumbsUpCount: $thumbsUpCount, thumbsDownCount: $thumbsDownCount, commentCount: $commentCount, ratingCount: $ratingCount, rating: $rating, tippedAmountCount: $tippedAmountCount)';
}


}

/// @nodoc
abstract mixin class $ModelStatsCopyWith<$Res>  {
  factory $ModelStatsCopyWith(ModelStats value, $Res Function(ModelStats) _then) = _$ModelStatsCopyWithImpl;
@useResult
$Res call({
 int downloadCount, int? favoriteCount, int thumbsUpCount, int? thumbsDownCount, int commentCount, int? ratingCount, double? rating, int tippedAmountCount
});




}
/// @nodoc
class _$ModelStatsCopyWithImpl<$Res>
    implements $ModelStatsCopyWith<$Res> {
  _$ModelStatsCopyWithImpl(this._self, this._then);

  final ModelStats _self;
  final $Res Function(ModelStats) _then;

/// Create a copy of ModelStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? downloadCount = null,Object? favoriteCount = freezed,Object? thumbsUpCount = null,Object? thumbsDownCount = freezed,Object? commentCount = null,Object? ratingCount = freezed,Object? rating = freezed,Object? tippedAmountCount = null,}) {
  return _then(_self.copyWith(
downloadCount: null == downloadCount ? _self.downloadCount : downloadCount // ignore: cast_nullable_to_non_nullable
as int,favoriteCount: freezed == favoriteCount ? _self.favoriteCount : favoriteCount // ignore: cast_nullable_to_non_nullable
as int?,thumbsUpCount: null == thumbsUpCount ? _self.thumbsUpCount : thumbsUpCount // ignore: cast_nullable_to_non_nullable
as int,thumbsDownCount: freezed == thumbsDownCount ? _self.thumbsDownCount : thumbsDownCount // ignore: cast_nullable_to_non_nullable
as int?,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,ratingCount: freezed == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,tippedAmountCount: null == tippedAmountCount ? _self.tippedAmountCount : tippedAmountCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ModelStats].
extension ModelStatsPatterns on ModelStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModelStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModelStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModelStats value)  $default,){
final _that = this;
switch (_that) {
case _ModelStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModelStats value)?  $default,){
final _that = this;
switch (_that) {
case _ModelStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int downloadCount,  int? favoriteCount,  int thumbsUpCount,  int? thumbsDownCount,  int commentCount,  int? ratingCount,  double? rating,  int tippedAmountCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModelStats() when $default != null:
return $default(_that.downloadCount,_that.favoriteCount,_that.thumbsUpCount,_that.thumbsDownCount,_that.commentCount,_that.ratingCount,_that.rating,_that.tippedAmountCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int downloadCount,  int? favoriteCount,  int thumbsUpCount,  int? thumbsDownCount,  int commentCount,  int? ratingCount,  double? rating,  int tippedAmountCount)  $default,) {final _that = this;
switch (_that) {
case _ModelStats():
return $default(_that.downloadCount,_that.favoriteCount,_that.thumbsUpCount,_that.thumbsDownCount,_that.commentCount,_that.ratingCount,_that.rating,_that.tippedAmountCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int downloadCount,  int? favoriteCount,  int thumbsUpCount,  int? thumbsDownCount,  int commentCount,  int? ratingCount,  double? rating,  int tippedAmountCount)?  $default,) {final _that = this;
switch (_that) {
case _ModelStats() when $default != null:
return $default(_that.downloadCount,_that.favoriteCount,_that.thumbsUpCount,_that.thumbsDownCount,_that.commentCount,_that.ratingCount,_that.rating,_that.tippedAmountCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModelStats implements ModelStats {
  const _ModelStats({this.downloadCount = 0, this.favoriteCount, this.thumbsUpCount = 0, this.thumbsDownCount, this.commentCount = 0, this.ratingCount, this.rating, this.tippedAmountCount = 0});
  factory _ModelStats.fromJson(Map<String, dynamic> json) => _$ModelStatsFromJson(json);

@override@JsonKey() final  int downloadCount;
@override final  int? favoriteCount;
@override@JsonKey() final  int thumbsUpCount;
@override final  int? thumbsDownCount;
@override@JsonKey() final  int commentCount;
@override final  int? ratingCount;
@override final  double? rating;
@override@JsonKey() final  int tippedAmountCount;

/// Create a copy of ModelStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelStatsCopyWith<_ModelStats> get copyWith => __$ModelStatsCopyWithImpl<_ModelStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModelStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModelStats&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.favoriteCount, favoriteCount) || other.favoriteCount == favoriteCount)&&(identical(other.thumbsUpCount, thumbsUpCount) || other.thumbsUpCount == thumbsUpCount)&&(identical(other.thumbsDownCount, thumbsDownCount) || other.thumbsDownCount == thumbsDownCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.tippedAmountCount, tippedAmountCount) || other.tippedAmountCount == tippedAmountCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,downloadCount,favoriteCount,thumbsUpCount,thumbsDownCount,commentCount,ratingCount,rating,tippedAmountCount);

@override
String toString() {
  return 'ModelStats(downloadCount: $downloadCount, favoriteCount: $favoriteCount, thumbsUpCount: $thumbsUpCount, thumbsDownCount: $thumbsDownCount, commentCount: $commentCount, ratingCount: $ratingCount, rating: $rating, tippedAmountCount: $tippedAmountCount)';
}


}

/// @nodoc
abstract mixin class _$ModelStatsCopyWith<$Res> implements $ModelStatsCopyWith<$Res> {
  factory _$ModelStatsCopyWith(_ModelStats value, $Res Function(_ModelStats) _then) = __$ModelStatsCopyWithImpl;
@override @useResult
$Res call({
 int downloadCount, int? favoriteCount, int thumbsUpCount, int? thumbsDownCount, int commentCount, int? ratingCount, double? rating, int tippedAmountCount
});




}
/// @nodoc
class __$ModelStatsCopyWithImpl<$Res>
    implements _$ModelStatsCopyWith<$Res> {
  __$ModelStatsCopyWithImpl(this._self, this._then);

  final _ModelStats _self;
  final $Res Function(_ModelStats) _then;

/// Create a copy of ModelStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? downloadCount = null,Object? favoriteCount = freezed,Object? thumbsUpCount = null,Object? thumbsDownCount = freezed,Object? commentCount = null,Object? ratingCount = freezed,Object? rating = freezed,Object? tippedAmountCount = null,}) {
  return _then(_ModelStats(
downloadCount: null == downloadCount ? _self.downloadCount : downloadCount // ignore: cast_nullable_to_non_nullable
as int,favoriteCount: freezed == favoriteCount ? _self.favoriteCount : favoriteCount // ignore: cast_nullable_to_non_nullable
as int?,thumbsUpCount: null == thumbsUpCount ? _self.thumbsUpCount : thumbsUpCount // ignore: cast_nullable_to_non_nullable
as int,thumbsDownCount: freezed == thumbsDownCount ? _self.thumbsDownCount : thumbsDownCount // ignore: cast_nullable_to_non_nullable
as int?,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,ratingCount: freezed == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,tippedAmountCount: null == tippedAmountCount ? _self.tippedAmountCount : tippedAmountCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PaginationMetadata {

 int? get totalItems; int? get currentPage; int? get pageSize; int? get totalPages; String? get nextPage; String? get prevPage;
/// Create a copy of PaginationMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginationMetadataCopyWith<PaginationMetadata> get copyWith => _$PaginationMetadataCopyWithImpl<PaginationMetadata>(this as PaginationMetadata, _$identity);

  /// Serializes this PaginationMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginationMetadata&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.nextPage, nextPage) || other.nextPage == nextPage)&&(identical(other.prevPage, prevPage) || other.prevPage == prevPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalItems,currentPage,pageSize,totalPages,nextPage,prevPage);

@override
String toString() {
  return 'PaginationMetadata(totalItems: $totalItems, currentPage: $currentPage, pageSize: $pageSize, totalPages: $totalPages, nextPage: $nextPage, prevPage: $prevPage)';
}


}

/// @nodoc
abstract mixin class $PaginationMetadataCopyWith<$Res>  {
  factory $PaginationMetadataCopyWith(PaginationMetadata value, $Res Function(PaginationMetadata) _then) = _$PaginationMetadataCopyWithImpl;
@useResult
$Res call({
 int? totalItems, int? currentPage, int? pageSize, int? totalPages, String? nextPage, String? prevPage
});




}
/// @nodoc
class _$PaginationMetadataCopyWithImpl<$Res>
    implements $PaginationMetadataCopyWith<$Res> {
  _$PaginationMetadataCopyWithImpl(this._self, this._then);

  final PaginationMetadata _self;
  final $Res Function(PaginationMetadata) _then;

/// Create a copy of PaginationMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalItems = freezed,Object? currentPage = freezed,Object? pageSize = freezed,Object? totalPages = freezed,Object? nextPage = freezed,Object? prevPage = freezed,}) {
  return _then(_self.copyWith(
totalItems: freezed == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int?,currentPage: freezed == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int?,pageSize: freezed == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int?,totalPages: freezed == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int?,nextPage: freezed == nextPage ? _self.nextPage : nextPage // ignore: cast_nullable_to_non_nullable
as String?,prevPage: freezed == prevPage ? _self.prevPage : prevPage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginationMetadata].
extension PaginationMetadataPatterns on PaginationMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginationMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginationMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginationMetadata value)  $default,){
final _that = this;
switch (_that) {
case _PaginationMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginationMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _PaginationMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? totalItems,  int? currentPage,  int? pageSize,  int? totalPages,  String? nextPage,  String? prevPage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginationMetadata() when $default != null:
return $default(_that.totalItems,_that.currentPage,_that.pageSize,_that.totalPages,_that.nextPage,_that.prevPage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? totalItems,  int? currentPage,  int? pageSize,  int? totalPages,  String? nextPage,  String? prevPage)  $default,) {final _that = this;
switch (_that) {
case _PaginationMetadata():
return $default(_that.totalItems,_that.currentPage,_that.pageSize,_that.totalPages,_that.nextPage,_that.prevPage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? totalItems,  int? currentPage,  int? pageSize,  int? totalPages,  String? nextPage,  String? prevPage)?  $default,) {final _that = this;
switch (_that) {
case _PaginationMetadata() when $default != null:
return $default(_that.totalItems,_that.currentPage,_that.pageSize,_that.totalPages,_that.nextPage,_that.prevPage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginationMetadata implements PaginationMetadata {
  const _PaginationMetadata({this.totalItems, this.currentPage, this.pageSize, this.totalPages, this.nextPage, this.prevPage});
  factory _PaginationMetadata.fromJson(Map<String, dynamic> json) => _$PaginationMetadataFromJson(json);

@override final  int? totalItems;
@override final  int? currentPage;
@override final  int? pageSize;
@override final  int? totalPages;
@override final  String? nextPage;
@override final  String? prevPage;

/// Create a copy of PaginationMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginationMetadataCopyWith<_PaginationMetadata> get copyWith => __$PaginationMetadataCopyWithImpl<_PaginationMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginationMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginationMetadata&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.nextPage, nextPage) || other.nextPage == nextPage)&&(identical(other.prevPage, prevPage) || other.prevPage == prevPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalItems,currentPage,pageSize,totalPages,nextPage,prevPage);

@override
String toString() {
  return 'PaginationMetadata(totalItems: $totalItems, currentPage: $currentPage, pageSize: $pageSize, totalPages: $totalPages, nextPage: $nextPage, prevPage: $prevPage)';
}


}

/// @nodoc
abstract mixin class _$PaginationMetadataCopyWith<$Res> implements $PaginationMetadataCopyWith<$Res> {
  factory _$PaginationMetadataCopyWith(_PaginationMetadata value, $Res Function(_PaginationMetadata) _then) = __$PaginationMetadataCopyWithImpl;
@override @useResult
$Res call({
 int? totalItems, int? currentPage, int? pageSize, int? totalPages, String? nextPage, String? prevPage
});




}
/// @nodoc
class __$PaginationMetadataCopyWithImpl<$Res>
    implements _$PaginationMetadataCopyWith<$Res> {
  __$PaginationMetadataCopyWithImpl(this._self, this._then);

  final _PaginationMetadata _self;
  final $Res Function(_PaginationMetadata) _then;

/// Create a copy of PaginationMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalItems = freezed,Object? currentPage = freezed,Object? pageSize = freezed,Object? totalPages = freezed,Object? nextPage = freezed,Object? prevPage = freezed,}) {
  return _then(_PaginationMetadata(
totalItems: freezed == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int?,currentPage: freezed == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int?,pageSize: freezed == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int?,totalPages: freezed == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int?,nextPage: freezed == nextPage ? _self.nextPage : nextPage // ignore: cast_nullable_to_non_nullable
as String?,prevPage: freezed == prevPage ? _self.prevPage : prevPage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
