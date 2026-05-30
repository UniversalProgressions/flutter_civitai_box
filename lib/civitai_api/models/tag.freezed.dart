// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TagItem {

 String get name; int get modelCount; String get link;
/// Create a copy of TagItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagItemCopyWith<TagItem> get copyWith => _$TagItemCopyWithImpl<TagItem>(this as TagItem, _$identity);

  /// Serializes this TagItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TagItem&&(identical(other.name, name) || other.name == name)&&(identical(other.modelCount, modelCount) || other.modelCount == modelCount)&&(identical(other.link, link) || other.link == link));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,modelCount,link);

@override
String toString() {
  return 'TagItem(name: $name, modelCount: $modelCount, link: $link)';
}


}

/// @nodoc
abstract mixin class $TagItemCopyWith<$Res>  {
  factory $TagItemCopyWith(TagItem value, $Res Function(TagItem) _then) = _$TagItemCopyWithImpl;
@useResult
$Res call({
 String name, int modelCount, String link
});




}
/// @nodoc
class _$TagItemCopyWithImpl<$Res>
    implements $TagItemCopyWith<$Res> {
  _$TagItemCopyWithImpl(this._self, this._then);

  final TagItem _self;
  final $Res Function(TagItem) _then;

/// Create a copy of TagItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? modelCount = null,Object? link = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,modelCount: null == modelCount ? _self.modelCount : modelCount // ignore: cast_nullable_to_non_nullable
as int,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TagItem].
extension TagItemPatterns on TagItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TagItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TagItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TagItem value)  $default,){
final _that = this;
switch (_that) {
case _TagItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TagItem value)?  $default,){
final _that = this;
switch (_that) {
case _TagItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int modelCount,  String link)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TagItem() when $default != null:
return $default(_that.name,_that.modelCount,_that.link);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int modelCount,  String link)  $default,) {final _that = this;
switch (_that) {
case _TagItem():
return $default(_that.name,_that.modelCount,_that.link);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int modelCount,  String link)?  $default,) {final _that = this;
switch (_that) {
case _TagItem() when $default != null:
return $default(_that.name,_that.modelCount,_that.link);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TagItem implements TagItem {
  const _TagItem({required this.name, required this.modelCount, required this.link});
  factory _TagItem.fromJson(Map<String, dynamic> json) => _$TagItemFromJson(json);

@override final  String name;
@override final  int modelCount;
@override final  String link;

/// Create a copy of TagItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagItemCopyWith<_TagItem> get copyWith => __$TagItemCopyWithImpl<_TagItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TagItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagItem&&(identical(other.name, name) || other.name == name)&&(identical(other.modelCount, modelCount) || other.modelCount == modelCount)&&(identical(other.link, link) || other.link == link));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,modelCount,link);

@override
String toString() {
  return 'TagItem(name: $name, modelCount: $modelCount, link: $link)';
}


}

/// @nodoc
abstract mixin class _$TagItemCopyWith<$Res> implements $TagItemCopyWith<$Res> {
  factory _$TagItemCopyWith(_TagItem value, $Res Function(_TagItem) _then) = __$TagItemCopyWithImpl;
@override @useResult
$Res call({
 String name, int modelCount, String link
});




}
/// @nodoc
class __$TagItemCopyWithImpl<$Res>
    implements _$TagItemCopyWith<$Res> {
  __$TagItemCopyWithImpl(this._self, this._then);

  final _TagItem _self;
  final $Res Function(_TagItem) _then;

/// Create a copy of TagItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? modelCount = null,Object? link = null,}) {
  return _then(_TagItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,modelCount: null == modelCount ? _self.modelCount : modelCount // ignore: cast_nullable_to_non_nullable
as int,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TagsResponse {

 List<TagItem> get items; PaginationMetadata get metadata;
/// Create a copy of TagsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagsResponseCopyWith<TagsResponse> get copyWith => _$TagsResponseCopyWithImpl<TagsResponse>(this as TagsResponse, _$identity);

  /// Serializes this TagsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TagsResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),metadata);

@override
String toString() {
  return 'TagsResponse(items: $items, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $TagsResponseCopyWith<$Res>  {
  factory $TagsResponseCopyWith(TagsResponse value, $Res Function(TagsResponse) _then) = _$TagsResponseCopyWithImpl;
@useResult
$Res call({
 List<TagItem> items, PaginationMetadata metadata
});


$PaginationMetadataCopyWith<$Res> get metadata;

}
/// @nodoc
class _$TagsResponseCopyWithImpl<$Res>
    implements $TagsResponseCopyWith<$Res> {
  _$TagsResponseCopyWithImpl(this._self, this._then);

  final TagsResponse _self;
  final $Res Function(TagsResponse) _then;

/// Create a copy of TagsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<TagItem>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as PaginationMetadata,
  ));
}
/// Create a copy of TagsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginationMetadataCopyWith<$Res> get metadata {
  
  return $PaginationMetadataCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [TagsResponse].
extension TagsResponsePatterns on TagsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TagsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TagsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TagsResponse value)  $default,){
final _that = this;
switch (_that) {
case _TagsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TagsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TagsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TagItem> items,  PaginationMetadata metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TagsResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TagItem> items,  PaginationMetadata metadata)  $default,) {final _that = this;
switch (_that) {
case _TagsResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TagItem> items,  PaginationMetadata metadata)?  $default,) {final _that = this;
switch (_that) {
case _TagsResponse() when $default != null:
return $default(_that.items,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TagsResponse implements TagsResponse {
  const _TagsResponse({required final  List<TagItem> items, this.metadata = const PaginationMetadata()}): _items = items;
  factory _TagsResponse.fromJson(Map<String, dynamic> json) => _$TagsResponseFromJson(json);

 final  List<TagItem> _items;
@override List<TagItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  PaginationMetadata metadata;

/// Create a copy of TagsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagsResponseCopyWith<_TagsResponse> get copyWith => __$TagsResponseCopyWithImpl<_TagsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TagsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagsResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),metadata);

@override
String toString() {
  return 'TagsResponse(items: $items, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$TagsResponseCopyWith<$Res> implements $TagsResponseCopyWith<$Res> {
  factory _$TagsResponseCopyWith(_TagsResponse value, $Res Function(_TagsResponse) _then) = __$TagsResponseCopyWithImpl;
@override @useResult
$Res call({
 List<TagItem> items, PaginationMetadata metadata
});


@override $PaginationMetadataCopyWith<$Res> get metadata;

}
/// @nodoc
class __$TagsResponseCopyWithImpl<$Res>
    implements _$TagsResponseCopyWith<$Res> {
  __$TagsResponseCopyWithImpl(this._self, this._then);

  final _TagsResponse _self;
  final $Res Function(_TagsResponse) _then;

/// Create a copy of TagsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? metadata = null,}) {
  return _then(_TagsResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<TagItem>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as PaginationMetadata,
  ));
}

/// Create a copy of TagsResponse
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
