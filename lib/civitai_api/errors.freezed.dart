// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'errors.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CivitaiError {

 String get message;
/// Create a copy of CivitaiError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CivitaiErrorCopyWith<CivitaiError> get copyWith => _$CivitaiErrorCopyWithImpl<CivitaiError>(this as CivitaiError, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CivitaiError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'CivitaiError(message: $message)';
}


}

/// @nodoc
abstract mixin class $CivitaiErrorCopyWith<$Res>  {
  factory $CivitaiErrorCopyWith(CivitaiError value, $Res Function(CivitaiError) _then) = _$CivitaiErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$CivitaiErrorCopyWithImpl<$Res>
    implements $CivitaiErrorCopyWith<$Res> {
  _$CivitaiErrorCopyWithImpl(this._self, this._then);

  final CivitaiError _self;
  final $Res Function(CivitaiError) _then;

/// Create a copy of CivitaiError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CivitaiError].
extension CivitaiErrorPatterns on CivitaiError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ApiError value)?  api,TResult Function( NetworkError value)?  network,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ApiError() when api != null:
return api(_that);case NetworkError() when network != null:
return network(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ApiError value)  api,required TResult Function( NetworkError value)  network,}){
final _that = this;
switch (_that) {
case ApiError():
return api(_that);case NetworkError():
return network(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ApiError value)?  api,TResult? Function( NetworkError value)?  network,}){
final _that = this;
switch (_that) {
case ApiError() when api != null:
return api(_that);case NetworkError() when network != null:
return network(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int statusCode,  String message,  Map<String, dynamic>? details)?  api,TResult Function( String message,  Object? cause)?  network,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ApiError() when api != null:
return api(_that.statusCode,_that.message,_that.details);case NetworkError() when network != null:
return network(_that.message,_that.cause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int statusCode,  String message,  Map<String, dynamic>? details)  api,required TResult Function( String message,  Object? cause)  network,}) {final _that = this;
switch (_that) {
case ApiError():
return api(_that.statusCode,_that.message,_that.details);case NetworkError():
return network(_that.message,_that.cause);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int statusCode,  String message,  Map<String, dynamic>? details)?  api,TResult? Function( String message,  Object? cause)?  network,}) {final _that = this;
switch (_that) {
case ApiError() when api != null:
return api(_that.statusCode,_that.message,_that.details);case NetworkError() when network != null:
return network(_that.message,_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class ApiError implements CivitaiError {
  const ApiError(this.statusCode, this.message, [final  Map<String, dynamic>? details]): _details = details;
  

 final  int statusCode;
@override final  String message;
 final  Map<String, dynamic>? _details;
 Map<String, dynamic>? get details {
  final value = _details;
  if (value == null) return null;
  if (_details is EqualUnmodifiableMapView) return _details;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of CivitaiError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiErrorCopyWith<ApiError> get copyWith => _$ApiErrorCopyWithImpl<ApiError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiError&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._details, _details));
}


@override
int get hashCode => Object.hash(runtimeType,statusCode,message,const DeepCollectionEquality().hash(_details));

@override
String toString() {
  return 'CivitaiError.api(statusCode: $statusCode, message: $message, details: $details)';
}


}

/// @nodoc
abstract mixin class $ApiErrorCopyWith<$Res> implements $CivitaiErrorCopyWith<$Res> {
  factory $ApiErrorCopyWith(ApiError value, $Res Function(ApiError) _then) = _$ApiErrorCopyWithImpl;
@override @useResult
$Res call({
 int statusCode, String message, Map<String, dynamic>? details
});




}
/// @nodoc
class _$ApiErrorCopyWithImpl<$Res>
    implements $ApiErrorCopyWith<$Res> {
  _$ApiErrorCopyWithImpl(this._self, this._then);

  final ApiError _self;
  final $Res Function(ApiError) _then;

/// Create a copy of CivitaiError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? statusCode = null,Object? message = null,Object? details = freezed,}) {
  return _then(ApiError(
null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,freezed == details ? _self._details : details // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

/// @nodoc


class NetworkError implements CivitaiError {
  const NetworkError(this.message, [this.cause]);
  

@override final  String message;
 final  Object? cause;

/// Create a copy of CivitaiError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkErrorCopyWith<NetworkError> get copyWith => _$NetworkErrorCopyWithImpl<NetworkError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkError&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.cause, cause));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(cause));

@override
String toString() {
  return 'CivitaiError.network(message: $message, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $NetworkErrorCopyWith<$Res> implements $CivitaiErrorCopyWith<$Res> {
  factory $NetworkErrorCopyWith(NetworkError value, $Res Function(NetworkError) _then) = _$NetworkErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, Object? cause
});




}
/// @nodoc
class _$NetworkErrorCopyWithImpl<$Res>
    implements $NetworkErrorCopyWith<$Res> {
  _$NetworkErrorCopyWithImpl(this._self, this._then);

  final NetworkError _self;
  final $Res Function(NetworkError) _then;

/// Create a copy of CivitaiError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? cause = freezed,}) {
  return _then(NetworkError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,freezed == cause ? _self.cause : cause ,
  ));
}


}

// dart format on
