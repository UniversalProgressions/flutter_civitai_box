// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CivitaiConfig {

 String get apiKey; String get downloadToken; String get baseUrl; int get timeout; Map<String, String> get headers; bool get validateResponses;
/// Create a copy of CivitaiConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CivitaiConfigCopyWith<CivitaiConfig> get copyWith => _$CivitaiConfigCopyWithImpl<CivitaiConfig>(this as CivitaiConfig, _$identity);

  /// Serializes this CivitaiConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CivitaiConfig&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey)&&(identical(other.downloadToken, downloadToken) || other.downloadToken == downloadToken)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&const DeepCollectionEquality().equals(other.headers, headers)&&(identical(other.validateResponses, validateResponses) || other.validateResponses == validateResponses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,apiKey,downloadToken,baseUrl,timeout,const DeepCollectionEquality().hash(headers),validateResponses);

@override
String toString() {
  return 'CivitaiConfig(apiKey: $apiKey, downloadToken: $downloadToken, baseUrl: $baseUrl, timeout: $timeout, headers: $headers, validateResponses: $validateResponses)';
}


}

/// @nodoc
abstract mixin class $CivitaiConfigCopyWith<$Res>  {
  factory $CivitaiConfigCopyWith(CivitaiConfig value, $Res Function(CivitaiConfig) _then) = _$CivitaiConfigCopyWithImpl;
@useResult
$Res call({
 String apiKey, String downloadToken, String baseUrl, int timeout, Map<String, String> headers, bool validateResponses
});




}
/// @nodoc
class _$CivitaiConfigCopyWithImpl<$Res>
    implements $CivitaiConfigCopyWith<$Res> {
  _$CivitaiConfigCopyWithImpl(this._self, this._then);

  final CivitaiConfig _self;
  final $Res Function(CivitaiConfig) _then;

/// Create a copy of CivitaiConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? apiKey = null,Object? downloadToken = null,Object? baseUrl = null,Object? timeout = null,Object? headers = null,Object? validateResponses = null,}) {
  return _then(_self.copyWith(
apiKey: null == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String,downloadToken: null == downloadToken ? _self.downloadToken : downloadToken // ignore: cast_nullable_to_non_nullable
as String,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,timeout: null == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int,headers: null == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,validateResponses: null == validateResponses ? _self.validateResponses : validateResponses // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CivitaiConfig].
extension CivitaiConfigPatterns on CivitaiConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CivitaiConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CivitaiConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CivitaiConfig value)  $default,){
final _that = this;
switch (_that) {
case _CivitaiConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CivitaiConfig value)?  $default,){
final _that = this;
switch (_that) {
case _CivitaiConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String apiKey,  String downloadToken,  String baseUrl,  int timeout,  Map<String, String> headers,  bool validateResponses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CivitaiConfig() when $default != null:
return $default(_that.apiKey,_that.downloadToken,_that.baseUrl,_that.timeout,_that.headers,_that.validateResponses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String apiKey,  String downloadToken,  String baseUrl,  int timeout,  Map<String, String> headers,  bool validateResponses)  $default,) {final _that = this;
switch (_that) {
case _CivitaiConfig():
return $default(_that.apiKey,_that.downloadToken,_that.baseUrl,_that.timeout,_that.headers,_that.validateResponses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String apiKey,  String downloadToken,  String baseUrl,  int timeout,  Map<String, String> headers,  bool validateResponses)?  $default,) {final _that = this;
switch (_that) {
case _CivitaiConfig() when $default != null:
return $default(_that.apiKey,_that.downloadToken,_that.baseUrl,_that.timeout,_that.headers,_that.validateResponses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CivitaiConfig implements CivitaiConfig {
  const _CivitaiConfig({this.apiKey = '', this.downloadToken = '', this.baseUrl = 'https://civitai.com/api/v1', this.timeout = 30000, final  Map<String, String> headers = const {}, this.validateResponses = false}): _headers = headers;
  factory _CivitaiConfig.fromJson(Map<String, dynamic> json) => _$CivitaiConfigFromJson(json);

@override@JsonKey() final  String apiKey;
@override@JsonKey() final  String downloadToken;
@override@JsonKey() final  String baseUrl;
@override@JsonKey() final  int timeout;
 final  Map<String, String> _headers;
@override@JsonKey() Map<String, String> get headers {
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_headers);
}

@override@JsonKey() final  bool validateResponses;

/// Create a copy of CivitaiConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CivitaiConfigCopyWith<_CivitaiConfig> get copyWith => __$CivitaiConfigCopyWithImpl<_CivitaiConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CivitaiConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CivitaiConfig&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey)&&(identical(other.downloadToken, downloadToken) || other.downloadToken == downloadToken)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&const DeepCollectionEquality().equals(other._headers, _headers)&&(identical(other.validateResponses, validateResponses) || other.validateResponses == validateResponses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,apiKey,downloadToken,baseUrl,timeout,const DeepCollectionEquality().hash(_headers),validateResponses);

@override
String toString() {
  return 'CivitaiConfig(apiKey: $apiKey, downloadToken: $downloadToken, baseUrl: $baseUrl, timeout: $timeout, headers: $headers, validateResponses: $validateResponses)';
}


}

/// @nodoc
abstract mixin class _$CivitaiConfigCopyWith<$Res> implements $CivitaiConfigCopyWith<$Res> {
  factory _$CivitaiConfigCopyWith(_CivitaiConfig value, $Res Function(_CivitaiConfig) _then) = __$CivitaiConfigCopyWithImpl;
@override @useResult
$Res call({
 String apiKey, String downloadToken, String baseUrl, int timeout, Map<String, String> headers, bool validateResponses
});




}
/// @nodoc
class __$CivitaiConfigCopyWithImpl<$Res>
    implements _$CivitaiConfigCopyWith<$Res> {
  __$CivitaiConfigCopyWithImpl(this._self, this._then);

  final _CivitaiConfig _self;
  final $Res Function(_CivitaiConfig) _then;

/// Create a copy of CivitaiConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? apiKey = null,Object? downloadToken = null,Object? baseUrl = null,Object? timeout = null,Object? headers = null,Object? validateResponses = null,}) {
  return _then(_CivitaiConfig(
apiKey: null == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String,downloadToken: null == downloadToken ? _self.downloadToken : downloadToken // ignore: cast_nullable_to_non_nullable
as String,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,timeout: null == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int,headers: null == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,validateResponses: null == validateResponses ? _self.validateResponses : validateResponses // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
