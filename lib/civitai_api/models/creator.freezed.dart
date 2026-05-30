// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'creator.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Creator {

 String get username; int? get modelCount; String? get link; String? get image;
/// Create a copy of Creator
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatorCopyWith<Creator> get copyWith => _$CreatorCopyWithImpl<Creator>(this as Creator, _$identity);

  /// Serializes this Creator to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Creator&&(identical(other.username, username) || other.username == username)&&(identical(other.modelCount, modelCount) || other.modelCount == modelCount)&&(identical(other.link, link) || other.link == link)&&(identical(other.image, image) || other.image == image));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,modelCount,link,image);

@override
String toString() {
  return 'Creator(username: $username, modelCount: $modelCount, link: $link, image: $image)';
}


}

/// @nodoc
abstract mixin class $CreatorCopyWith<$Res>  {
  factory $CreatorCopyWith(Creator value, $Res Function(Creator) _then) = _$CreatorCopyWithImpl;
@useResult
$Res call({
 String username, int? modelCount, String? link, String? image
});




}
/// @nodoc
class _$CreatorCopyWithImpl<$Res>
    implements $CreatorCopyWith<$Res> {
  _$CreatorCopyWithImpl(this._self, this._then);

  final Creator _self;
  final $Res Function(Creator) _then;

/// Create a copy of Creator
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? modelCount = freezed,Object? link = freezed,Object? image = freezed,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,modelCount: freezed == modelCount ? _self.modelCount : modelCount // ignore: cast_nullable_to_non_nullable
as int?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Creator].
extension CreatorPatterns on Creator {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Creator value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Creator() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Creator value)  $default,){
final _that = this;
switch (_that) {
case _Creator():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Creator value)?  $default,){
final _that = this;
switch (_that) {
case _Creator() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  int? modelCount,  String? link,  String? image)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Creator() when $default != null:
return $default(_that.username,_that.modelCount,_that.link,_that.image);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  int? modelCount,  String? link,  String? image)  $default,) {final _that = this;
switch (_that) {
case _Creator():
return $default(_that.username,_that.modelCount,_that.link,_that.image);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  int? modelCount,  String? link,  String? image)?  $default,) {final _that = this;
switch (_that) {
case _Creator() when $default != null:
return $default(_that.username,_that.modelCount,_that.link,_that.image);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Creator implements Creator {
  const _Creator({this.username = '', this.modelCount, this.link, this.image});
  factory _Creator.fromJson(Map<String, dynamic> json) => _$CreatorFromJson(json);

@override@JsonKey() final  String username;
@override final  int? modelCount;
@override final  String? link;
@override final  String? image;

/// Create a copy of Creator
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatorCopyWith<_Creator> get copyWith => __$CreatorCopyWithImpl<_Creator>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Creator&&(identical(other.username, username) || other.username == username)&&(identical(other.modelCount, modelCount) || other.modelCount == modelCount)&&(identical(other.link, link) || other.link == link)&&(identical(other.image, image) || other.image == image));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,modelCount,link,image);

@override
String toString() {
  return 'Creator(username: $username, modelCount: $modelCount, link: $link, image: $image)';
}


}

/// @nodoc
abstract mixin class _$CreatorCopyWith<$Res> implements $CreatorCopyWith<$Res> {
  factory _$CreatorCopyWith(_Creator value, $Res Function(_Creator) _then) = __$CreatorCopyWithImpl;
@override @useResult
$Res call({
 String username, int? modelCount, String? link, String? image
});




}
/// @nodoc
class __$CreatorCopyWithImpl<$Res>
    implements _$CreatorCopyWith<$Res> {
  __$CreatorCopyWithImpl(this._self, this._then);

  final _Creator _self;
  final $Res Function(_Creator) _then;

/// Create a copy of Creator
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? modelCount = freezed,Object? link = freezed,Object? image = freezed,}) {
  return _then(_Creator(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,modelCount: freezed == modelCount ? _self.modelCount : modelCount // ignore: cast_nullable_to_non_nullable
as int?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreatorsResponse {

 List<Creator> get items; PaginationMetadata get metadata;
/// Create a copy of CreatorsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatorsResponseCopyWith<CreatorsResponse> get copyWith => _$CreatorsResponseCopyWithImpl<CreatorsResponse>(this as CreatorsResponse, _$identity);

  /// Serializes this CreatorsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatorsResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),metadata);

@override
String toString() {
  return 'CreatorsResponse(items: $items, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $CreatorsResponseCopyWith<$Res>  {
  factory $CreatorsResponseCopyWith(CreatorsResponse value, $Res Function(CreatorsResponse) _then) = _$CreatorsResponseCopyWithImpl;
@useResult
$Res call({
 List<Creator> items, PaginationMetadata metadata
});


$PaginationMetadataCopyWith<$Res> get metadata;

}
/// @nodoc
class _$CreatorsResponseCopyWithImpl<$Res>
    implements $CreatorsResponseCopyWith<$Res> {
  _$CreatorsResponseCopyWithImpl(this._self, this._then);

  final CreatorsResponse _self;
  final $Res Function(CreatorsResponse) _then;

/// Create a copy of CreatorsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Creator>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as PaginationMetadata,
  ));
}
/// Create a copy of CreatorsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginationMetadataCopyWith<$Res> get metadata {
  
  return $PaginationMetadataCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreatorsResponse].
extension CreatorsResponsePatterns on CreatorsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatorsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatorsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatorsResponse value)  $default,){
final _that = this;
switch (_that) {
case _CreatorsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatorsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CreatorsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Creator> items,  PaginationMetadata metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatorsResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Creator> items,  PaginationMetadata metadata)  $default,) {final _that = this;
switch (_that) {
case _CreatorsResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Creator> items,  PaginationMetadata metadata)?  $default,) {final _that = this;
switch (_that) {
case _CreatorsResponse() when $default != null:
return $default(_that.items,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreatorsResponse implements CreatorsResponse {
  const _CreatorsResponse({required final  List<Creator> items, this.metadata = const PaginationMetadata()}): _items = items;
  factory _CreatorsResponse.fromJson(Map<String, dynamic> json) => _$CreatorsResponseFromJson(json);

 final  List<Creator> _items;
@override List<Creator> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  PaginationMetadata metadata;

/// Create a copy of CreatorsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatorsResponseCopyWith<_CreatorsResponse> get copyWith => __$CreatorsResponseCopyWithImpl<_CreatorsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatorsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatorsResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),metadata);

@override
String toString() {
  return 'CreatorsResponse(items: $items, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$CreatorsResponseCopyWith<$Res> implements $CreatorsResponseCopyWith<$Res> {
  factory _$CreatorsResponseCopyWith(_CreatorsResponse value, $Res Function(_CreatorsResponse) _then) = __$CreatorsResponseCopyWithImpl;
@override @useResult
$Res call({
 List<Creator> items, PaginationMetadata metadata
});


@override $PaginationMetadataCopyWith<$Res> get metadata;

}
/// @nodoc
class __$CreatorsResponseCopyWithImpl<$Res>
    implements _$CreatorsResponseCopyWith<$Res> {
  __$CreatorsResponseCopyWithImpl(this._self, this._then);

  final _CreatorsResponse _self;
  final $Res Function(_CreatorsResponse) _then;

/// Create a copy of CreatorsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? metadata = null,}) {
  return _then(_CreatorsResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Creator>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as PaginationMetadata,
  ));
}

/// Create a copy of CreatorsResponse
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
