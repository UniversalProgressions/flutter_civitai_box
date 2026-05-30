// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_options.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ModelsRequestOptions {

/// Results per page (1–100).
 int? get limit;/// Page number (cannot be used with query search — use cursor-based).
 int? get page;/// Search query to filter models by name.
 String? get query;/// Filter by tag(s).
 List<String>? get tag;/// Filter by creator username.
 String? get username;/// Filter by model type(s).
 List<ModelType>? get types;/// Sort order.
 ModelsSort? get sort;/// Time period for sorting.
 ModelsPeriod? get period;/// Filter by rating.
 int? get rating;/// (AUTHED) Filter to favorites.
 bool? get favorites;/// (AUTHED) Filter to hidden models.
 bool? get hidden;/// Only include primary file per model.
 bool? get primaryFileOnly;/// Filter by license derivatives.
 bool? get allowDifferentLicenses;/// Filter by commercial use permissions.
 List<AllowCommercialUse>? get allowCommercialUse;/// If false, return safer images and hide models without safe images.
 bool? get nsfw;/// If true, only return models that support generation.
 bool? get supportsGeneration;/// Filter by checkpoint type.
 CheckpointType? get checkpointType;/// Filter by base model(s).
 List<BaseModel>? get baseModels;
/// Create a copy of ModelsRequestOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModelsRequestOptionsCopyWith<ModelsRequestOptions> get copyWith => _$ModelsRequestOptionsCopyWithImpl<ModelsRequestOptions>(this as ModelsRequestOptions, _$identity);

  /// Serializes this ModelsRequestOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModelsRequestOptions&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.page, page) || other.page == page)&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other.tag, tag)&&(identical(other.username, username) || other.username == username)&&const DeepCollectionEquality().equals(other.types, types)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.period, period) || other.period == period)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.favorites, favorites) || other.favorites == favorites)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.primaryFileOnly, primaryFileOnly) || other.primaryFileOnly == primaryFileOnly)&&(identical(other.allowDifferentLicenses, allowDifferentLicenses) || other.allowDifferentLicenses == allowDifferentLicenses)&&const DeepCollectionEquality().equals(other.allowCommercialUse, allowCommercialUse)&&(identical(other.nsfw, nsfw) || other.nsfw == nsfw)&&(identical(other.supportsGeneration, supportsGeneration) || other.supportsGeneration == supportsGeneration)&&(identical(other.checkpointType, checkpointType) || other.checkpointType == checkpointType)&&const DeepCollectionEquality().equals(other.baseModels, baseModels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,limit,page,query,const DeepCollectionEquality().hash(tag),username,const DeepCollectionEquality().hash(types),sort,period,rating,favorites,hidden,primaryFileOnly,allowDifferentLicenses,const DeepCollectionEquality().hash(allowCommercialUse),nsfw,supportsGeneration,checkpointType,const DeepCollectionEquality().hash(baseModels));

@override
String toString() {
  return 'ModelsRequestOptions(limit: $limit, page: $page, query: $query, tag: $tag, username: $username, types: $types, sort: $sort, period: $period, rating: $rating, favorites: $favorites, hidden: $hidden, primaryFileOnly: $primaryFileOnly, allowDifferentLicenses: $allowDifferentLicenses, allowCommercialUse: $allowCommercialUse, nsfw: $nsfw, supportsGeneration: $supportsGeneration, checkpointType: $checkpointType, baseModels: $baseModels)';
}


}

/// @nodoc
abstract mixin class $ModelsRequestOptionsCopyWith<$Res>  {
  factory $ModelsRequestOptionsCopyWith(ModelsRequestOptions value, $Res Function(ModelsRequestOptions) _then) = _$ModelsRequestOptionsCopyWithImpl;
@useResult
$Res call({
 int? limit, int? page, String? query, List<String>? tag, String? username, List<ModelType>? types, ModelsSort? sort, ModelsPeriod? period, int? rating, bool? favorites, bool? hidden, bool? primaryFileOnly, bool? allowDifferentLicenses, List<AllowCommercialUse>? allowCommercialUse, bool? nsfw, bool? supportsGeneration, CheckpointType? checkpointType, List<BaseModel>? baseModels
});




}
/// @nodoc
class _$ModelsRequestOptionsCopyWithImpl<$Res>
    implements $ModelsRequestOptionsCopyWith<$Res> {
  _$ModelsRequestOptionsCopyWithImpl(this._self, this._then);

  final ModelsRequestOptions _self;
  final $Res Function(ModelsRequestOptions) _then;

/// Create a copy of ModelsRequestOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? limit = freezed,Object? page = freezed,Object? query = freezed,Object? tag = freezed,Object? username = freezed,Object? types = freezed,Object? sort = freezed,Object? period = freezed,Object? rating = freezed,Object? favorites = freezed,Object? hidden = freezed,Object? primaryFileOnly = freezed,Object? allowDifferentLicenses = freezed,Object? allowCommercialUse = freezed,Object? nsfw = freezed,Object? supportsGeneration = freezed,Object? checkpointType = freezed,Object? baseModels = freezed,}) {
  return _then(_self.copyWith(
limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,tag: freezed == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as List<String>?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,types: freezed == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as List<ModelType>?,sort: freezed == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as ModelsSort?,period: freezed == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ModelsPeriod?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,favorites: freezed == favorites ? _self.favorites : favorites // ignore: cast_nullable_to_non_nullable
as bool?,hidden: freezed == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool?,primaryFileOnly: freezed == primaryFileOnly ? _self.primaryFileOnly : primaryFileOnly // ignore: cast_nullable_to_non_nullable
as bool?,allowDifferentLicenses: freezed == allowDifferentLicenses ? _self.allowDifferentLicenses : allowDifferentLicenses // ignore: cast_nullable_to_non_nullable
as bool?,allowCommercialUse: freezed == allowCommercialUse ? _self.allowCommercialUse : allowCommercialUse // ignore: cast_nullable_to_non_nullable
as List<AllowCommercialUse>?,nsfw: freezed == nsfw ? _self.nsfw : nsfw // ignore: cast_nullable_to_non_nullable
as bool?,supportsGeneration: freezed == supportsGeneration ? _self.supportsGeneration : supportsGeneration // ignore: cast_nullable_to_non_nullable
as bool?,checkpointType: freezed == checkpointType ? _self.checkpointType : checkpointType // ignore: cast_nullable_to_non_nullable
as CheckpointType?,baseModels: freezed == baseModels ? _self.baseModels : baseModels // ignore: cast_nullable_to_non_nullable
as List<BaseModel>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModelsRequestOptions].
extension ModelsRequestOptionsPatterns on ModelsRequestOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModelsRequestOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModelsRequestOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModelsRequestOptions value)  $default,){
final _that = this;
switch (_that) {
case _ModelsRequestOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModelsRequestOptions value)?  $default,){
final _that = this;
switch (_that) {
case _ModelsRequestOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? limit,  int? page,  String? query,  List<String>? tag,  String? username,  List<ModelType>? types,  ModelsSort? sort,  ModelsPeriod? period,  int? rating,  bool? favorites,  bool? hidden,  bool? primaryFileOnly,  bool? allowDifferentLicenses,  List<AllowCommercialUse>? allowCommercialUse,  bool? nsfw,  bool? supportsGeneration,  CheckpointType? checkpointType,  List<BaseModel>? baseModels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModelsRequestOptions() when $default != null:
return $default(_that.limit,_that.page,_that.query,_that.tag,_that.username,_that.types,_that.sort,_that.period,_that.rating,_that.favorites,_that.hidden,_that.primaryFileOnly,_that.allowDifferentLicenses,_that.allowCommercialUse,_that.nsfw,_that.supportsGeneration,_that.checkpointType,_that.baseModels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? limit,  int? page,  String? query,  List<String>? tag,  String? username,  List<ModelType>? types,  ModelsSort? sort,  ModelsPeriod? period,  int? rating,  bool? favorites,  bool? hidden,  bool? primaryFileOnly,  bool? allowDifferentLicenses,  List<AllowCommercialUse>? allowCommercialUse,  bool? nsfw,  bool? supportsGeneration,  CheckpointType? checkpointType,  List<BaseModel>? baseModels)  $default,) {final _that = this;
switch (_that) {
case _ModelsRequestOptions():
return $default(_that.limit,_that.page,_that.query,_that.tag,_that.username,_that.types,_that.sort,_that.period,_that.rating,_that.favorites,_that.hidden,_that.primaryFileOnly,_that.allowDifferentLicenses,_that.allowCommercialUse,_that.nsfw,_that.supportsGeneration,_that.checkpointType,_that.baseModels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? limit,  int? page,  String? query,  List<String>? tag,  String? username,  List<ModelType>? types,  ModelsSort? sort,  ModelsPeriod? period,  int? rating,  bool? favorites,  bool? hidden,  bool? primaryFileOnly,  bool? allowDifferentLicenses,  List<AllowCommercialUse>? allowCommercialUse,  bool? nsfw,  bool? supportsGeneration,  CheckpointType? checkpointType,  List<BaseModel>? baseModels)?  $default,) {final _that = this;
switch (_that) {
case _ModelsRequestOptions() when $default != null:
return $default(_that.limit,_that.page,_that.query,_that.tag,_that.username,_that.types,_that.sort,_that.period,_that.rating,_that.favorites,_that.hidden,_that.primaryFileOnly,_that.allowDifferentLicenses,_that.allowCommercialUse,_that.nsfw,_that.supportsGeneration,_that.checkpointType,_that.baseModels);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModelsRequestOptions implements ModelsRequestOptions {
  const _ModelsRequestOptions({this.limit, this.page, this.query, final  List<String>? tag, this.username, final  List<ModelType>? types, this.sort, this.period, this.rating, this.favorites, this.hidden, this.primaryFileOnly, this.allowDifferentLicenses, final  List<AllowCommercialUse>? allowCommercialUse, this.nsfw, this.supportsGeneration, this.checkpointType, final  List<BaseModel>? baseModels}): _tag = tag,_types = types,_allowCommercialUse = allowCommercialUse,_baseModels = baseModels;
  factory _ModelsRequestOptions.fromJson(Map<String, dynamic> json) => _$ModelsRequestOptionsFromJson(json);

/// Results per page (1–100).
@override final  int? limit;
/// Page number (cannot be used with query search — use cursor-based).
@override final  int? page;
/// Search query to filter models by name.
@override final  String? query;
/// Filter by tag(s).
 final  List<String>? _tag;
/// Filter by tag(s).
@override List<String>? get tag {
  final value = _tag;
  if (value == null) return null;
  if (_tag is EqualUnmodifiableListView) return _tag;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Filter by creator username.
@override final  String? username;
/// Filter by model type(s).
 final  List<ModelType>? _types;
/// Filter by model type(s).
@override List<ModelType>? get types {
  final value = _types;
  if (value == null) return null;
  if (_types is EqualUnmodifiableListView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Sort order.
@override final  ModelsSort? sort;
/// Time period for sorting.
@override final  ModelsPeriod? period;
/// Filter by rating.
@override final  int? rating;
/// (AUTHED) Filter to favorites.
@override final  bool? favorites;
/// (AUTHED) Filter to hidden models.
@override final  bool? hidden;
/// Only include primary file per model.
@override final  bool? primaryFileOnly;
/// Filter by license derivatives.
@override final  bool? allowDifferentLicenses;
/// Filter by commercial use permissions.
 final  List<AllowCommercialUse>? _allowCommercialUse;
/// Filter by commercial use permissions.
@override List<AllowCommercialUse>? get allowCommercialUse {
  final value = _allowCommercialUse;
  if (value == null) return null;
  if (_allowCommercialUse is EqualUnmodifiableListView) return _allowCommercialUse;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// If false, return safer images and hide models without safe images.
@override final  bool? nsfw;
/// If true, only return models that support generation.
@override final  bool? supportsGeneration;
/// Filter by checkpoint type.
@override final  CheckpointType? checkpointType;
/// Filter by base model(s).
 final  List<BaseModel>? _baseModels;
/// Filter by base model(s).
@override List<BaseModel>? get baseModels {
  final value = _baseModels;
  if (value == null) return null;
  if (_baseModels is EqualUnmodifiableListView) return _baseModels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ModelsRequestOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModelsRequestOptionsCopyWith<_ModelsRequestOptions> get copyWith => __$ModelsRequestOptionsCopyWithImpl<_ModelsRequestOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModelsRequestOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModelsRequestOptions&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.page, page) || other.page == page)&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other._tag, _tag)&&(identical(other.username, username) || other.username == username)&&const DeepCollectionEquality().equals(other._types, _types)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.period, period) || other.period == period)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.favorites, favorites) || other.favorites == favorites)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.primaryFileOnly, primaryFileOnly) || other.primaryFileOnly == primaryFileOnly)&&(identical(other.allowDifferentLicenses, allowDifferentLicenses) || other.allowDifferentLicenses == allowDifferentLicenses)&&const DeepCollectionEquality().equals(other._allowCommercialUse, _allowCommercialUse)&&(identical(other.nsfw, nsfw) || other.nsfw == nsfw)&&(identical(other.supportsGeneration, supportsGeneration) || other.supportsGeneration == supportsGeneration)&&(identical(other.checkpointType, checkpointType) || other.checkpointType == checkpointType)&&const DeepCollectionEquality().equals(other._baseModels, _baseModels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,limit,page,query,const DeepCollectionEquality().hash(_tag),username,const DeepCollectionEquality().hash(_types),sort,period,rating,favorites,hidden,primaryFileOnly,allowDifferentLicenses,const DeepCollectionEquality().hash(_allowCommercialUse),nsfw,supportsGeneration,checkpointType,const DeepCollectionEquality().hash(_baseModels));

@override
String toString() {
  return 'ModelsRequestOptions(limit: $limit, page: $page, query: $query, tag: $tag, username: $username, types: $types, sort: $sort, period: $period, rating: $rating, favorites: $favorites, hidden: $hidden, primaryFileOnly: $primaryFileOnly, allowDifferentLicenses: $allowDifferentLicenses, allowCommercialUse: $allowCommercialUse, nsfw: $nsfw, supportsGeneration: $supportsGeneration, checkpointType: $checkpointType, baseModels: $baseModels)';
}


}

/// @nodoc
abstract mixin class _$ModelsRequestOptionsCopyWith<$Res> implements $ModelsRequestOptionsCopyWith<$Res> {
  factory _$ModelsRequestOptionsCopyWith(_ModelsRequestOptions value, $Res Function(_ModelsRequestOptions) _then) = __$ModelsRequestOptionsCopyWithImpl;
@override @useResult
$Res call({
 int? limit, int? page, String? query, List<String>? tag, String? username, List<ModelType>? types, ModelsSort? sort, ModelsPeriod? period, int? rating, bool? favorites, bool? hidden, bool? primaryFileOnly, bool? allowDifferentLicenses, List<AllowCommercialUse>? allowCommercialUse, bool? nsfw, bool? supportsGeneration, CheckpointType? checkpointType, List<BaseModel>? baseModels
});




}
/// @nodoc
class __$ModelsRequestOptionsCopyWithImpl<$Res>
    implements _$ModelsRequestOptionsCopyWith<$Res> {
  __$ModelsRequestOptionsCopyWithImpl(this._self, this._then);

  final _ModelsRequestOptions _self;
  final $Res Function(_ModelsRequestOptions) _then;

/// Create a copy of ModelsRequestOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? limit = freezed,Object? page = freezed,Object? query = freezed,Object? tag = freezed,Object? username = freezed,Object? types = freezed,Object? sort = freezed,Object? period = freezed,Object? rating = freezed,Object? favorites = freezed,Object? hidden = freezed,Object? primaryFileOnly = freezed,Object? allowDifferentLicenses = freezed,Object? allowCommercialUse = freezed,Object? nsfw = freezed,Object? supportsGeneration = freezed,Object? checkpointType = freezed,Object? baseModels = freezed,}) {
  return _then(_ModelsRequestOptions(
limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,tag: freezed == tag ? _self._tag : tag // ignore: cast_nullable_to_non_nullable
as List<String>?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,types: freezed == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as List<ModelType>?,sort: freezed == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as ModelsSort?,period: freezed == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ModelsPeriod?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,favorites: freezed == favorites ? _self.favorites : favorites // ignore: cast_nullable_to_non_nullable
as bool?,hidden: freezed == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool?,primaryFileOnly: freezed == primaryFileOnly ? _self.primaryFileOnly : primaryFileOnly // ignore: cast_nullable_to_non_nullable
as bool?,allowDifferentLicenses: freezed == allowDifferentLicenses ? _self.allowDifferentLicenses : allowDifferentLicenses // ignore: cast_nullable_to_non_nullable
as bool?,allowCommercialUse: freezed == allowCommercialUse ? _self._allowCommercialUse : allowCommercialUse // ignore: cast_nullable_to_non_nullable
as List<AllowCommercialUse>?,nsfw: freezed == nsfw ? _self.nsfw : nsfw // ignore: cast_nullable_to_non_nullable
as bool?,supportsGeneration: freezed == supportsGeneration ? _self.supportsGeneration : supportsGeneration // ignore: cast_nullable_to_non_nullable
as bool?,checkpointType: freezed == checkpointType ? _self.checkpointType : checkpointType // ignore: cast_nullable_to_non_nullable
as CheckpointType?,baseModels: freezed == baseModels ? _self._baseModels : baseModels // ignore: cast_nullable_to_non_nullable
as List<BaseModel>?,
  ));
}


}


/// @nodoc
mixin _$CreatorsRequestOptions {

 int? get limit; String? get query;
/// Create a copy of CreatorsRequestOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatorsRequestOptionsCopyWith<CreatorsRequestOptions> get copyWith => _$CreatorsRequestOptionsCopyWithImpl<CreatorsRequestOptions>(this as CreatorsRequestOptions, _$identity);

  /// Serializes this CreatorsRequestOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatorsRequestOptions&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.query, query) || other.query == query));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,limit,query);

@override
String toString() {
  return 'CreatorsRequestOptions(limit: $limit, query: $query)';
}


}

/// @nodoc
abstract mixin class $CreatorsRequestOptionsCopyWith<$Res>  {
  factory $CreatorsRequestOptionsCopyWith(CreatorsRequestOptions value, $Res Function(CreatorsRequestOptions) _then) = _$CreatorsRequestOptionsCopyWithImpl;
@useResult
$Res call({
 int? limit, String? query
});




}
/// @nodoc
class _$CreatorsRequestOptionsCopyWithImpl<$Res>
    implements $CreatorsRequestOptionsCopyWith<$Res> {
  _$CreatorsRequestOptionsCopyWithImpl(this._self, this._then);

  final CreatorsRequestOptions _self;
  final $Res Function(CreatorsRequestOptions) _then;

/// Create a copy of CreatorsRequestOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? limit = freezed,Object? query = freezed,}) {
  return _then(_self.copyWith(
limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreatorsRequestOptions].
extension CreatorsRequestOptionsPatterns on CreatorsRequestOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatorsRequestOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatorsRequestOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatorsRequestOptions value)  $default,){
final _that = this;
switch (_that) {
case _CreatorsRequestOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatorsRequestOptions value)?  $default,){
final _that = this;
switch (_that) {
case _CreatorsRequestOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? limit,  String? query)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatorsRequestOptions() when $default != null:
return $default(_that.limit,_that.query);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? limit,  String? query)  $default,) {final _that = this;
switch (_that) {
case _CreatorsRequestOptions():
return $default(_that.limit,_that.query);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? limit,  String? query)?  $default,) {final _that = this;
switch (_that) {
case _CreatorsRequestOptions() when $default != null:
return $default(_that.limit,_that.query);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreatorsRequestOptions implements CreatorsRequestOptions {
  const _CreatorsRequestOptions({this.limit, this.query});
  factory _CreatorsRequestOptions.fromJson(Map<String, dynamic> json) => _$CreatorsRequestOptionsFromJson(json);

@override final  int? limit;
@override final  String? query;

/// Create a copy of CreatorsRequestOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatorsRequestOptionsCopyWith<_CreatorsRequestOptions> get copyWith => __$CreatorsRequestOptionsCopyWithImpl<_CreatorsRequestOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatorsRequestOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatorsRequestOptions&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.query, query) || other.query == query));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,limit,query);

@override
String toString() {
  return 'CreatorsRequestOptions(limit: $limit, query: $query)';
}


}

/// @nodoc
abstract mixin class _$CreatorsRequestOptionsCopyWith<$Res> implements $CreatorsRequestOptionsCopyWith<$Res> {
  factory _$CreatorsRequestOptionsCopyWith(_CreatorsRequestOptions value, $Res Function(_CreatorsRequestOptions) _then) = __$CreatorsRequestOptionsCopyWithImpl;
@override @useResult
$Res call({
 int? limit, String? query
});




}
/// @nodoc
class __$CreatorsRequestOptionsCopyWithImpl<$Res>
    implements _$CreatorsRequestOptionsCopyWith<$Res> {
  __$CreatorsRequestOptionsCopyWithImpl(this._self, this._then);

  final _CreatorsRequestOptions _self;
  final $Res Function(_CreatorsRequestOptions) _then;

/// Create a copy of CreatorsRequestOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? limit = freezed,Object? query = freezed,}) {
  return _then(_CreatorsRequestOptions(
limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TagsRequestOptions {

 int? get limit; String? get query;
/// Create a copy of TagsRequestOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagsRequestOptionsCopyWith<TagsRequestOptions> get copyWith => _$TagsRequestOptionsCopyWithImpl<TagsRequestOptions>(this as TagsRequestOptions, _$identity);

  /// Serializes this TagsRequestOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TagsRequestOptions&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.query, query) || other.query == query));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,limit,query);

@override
String toString() {
  return 'TagsRequestOptions(limit: $limit, query: $query)';
}


}

/// @nodoc
abstract mixin class $TagsRequestOptionsCopyWith<$Res>  {
  factory $TagsRequestOptionsCopyWith(TagsRequestOptions value, $Res Function(TagsRequestOptions) _then) = _$TagsRequestOptionsCopyWithImpl;
@useResult
$Res call({
 int? limit, String? query
});




}
/// @nodoc
class _$TagsRequestOptionsCopyWithImpl<$Res>
    implements $TagsRequestOptionsCopyWith<$Res> {
  _$TagsRequestOptionsCopyWithImpl(this._self, this._then);

  final TagsRequestOptions _self;
  final $Res Function(TagsRequestOptions) _then;

/// Create a copy of TagsRequestOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? limit = freezed,Object? query = freezed,}) {
  return _then(_self.copyWith(
limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TagsRequestOptions].
extension TagsRequestOptionsPatterns on TagsRequestOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TagsRequestOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TagsRequestOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TagsRequestOptions value)  $default,){
final _that = this;
switch (_that) {
case _TagsRequestOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TagsRequestOptions value)?  $default,){
final _that = this;
switch (_that) {
case _TagsRequestOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? limit,  String? query)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TagsRequestOptions() when $default != null:
return $default(_that.limit,_that.query);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? limit,  String? query)  $default,) {final _that = this;
switch (_that) {
case _TagsRequestOptions():
return $default(_that.limit,_that.query);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? limit,  String? query)?  $default,) {final _that = this;
switch (_that) {
case _TagsRequestOptions() when $default != null:
return $default(_that.limit,_that.query);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TagsRequestOptions implements TagsRequestOptions {
  const _TagsRequestOptions({this.limit, this.query});
  factory _TagsRequestOptions.fromJson(Map<String, dynamic> json) => _$TagsRequestOptionsFromJson(json);

@override final  int? limit;
@override final  String? query;

/// Create a copy of TagsRequestOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagsRequestOptionsCopyWith<_TagsRequestOptions> get copyWith => __$TagsRequestOptionsCopyWithImpl<_TagsRequestOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TagsRequestOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagsRequestOptions&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.query, query) || other.query == query));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,limit,query);

@override
String toString() {
  return 'TagsRequestOptions(limit: $limit, query: $query)';
}


}

/// @nodoc
abstract mixin class _$TagsRequestOptionsCopyWith<$Res> implements $TagsRequestOptionsCopyWith<$Res> {
  factory _$TagsRequestOptionsCopyWith(_TagsRequestOptions value, $Res Function(_TagsRequestOptions) _then) = __$TagsRequestOptionsCopyWithImpl;
@override @useResult
$Res call({
 int? limit, String? query
});




}
/// @nodoc
class __$TagsRequestOptionsCopyWithImpl<$Res>
    implements _$TagsRequestOptionsCopyWith<$Res> {
  __$TagsRequestOptionsCopyWithImpl(this._self, this._then);

  final _TagsRequestOptions _self;
  final $Res Function(_TagsRequestOptions) _then;

/// Create a copy of TagsRequestOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? limit = freezed,Object? query = freezed,}) {
  return _then(_TagsRequestOptions(
limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
