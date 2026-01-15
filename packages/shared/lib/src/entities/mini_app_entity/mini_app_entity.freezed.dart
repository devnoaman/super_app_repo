// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mini_app_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MiniAppEntity {

 String get id; String get name; String get logoUrl; String get description; String get url;// The URL to load in the WebView
 String get apiKey;// The URL to load in the WebView
@ColorConverter() Color get primaryColor; List<String> get requiredPermissions;
/// Create a copy of MiniAppEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MiniAppEntityCopyWith<MiniAppEntity> get copyWith => _$MiniAppEntityCopyWithImpl<MiniAppEntity>(this as MiniAppEntity, _$identity);

  /// Serializes this MiniAppEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MiniAppEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.url, url) || other.url == url)&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&const DeepCollectionEquality().equals(other.requiredPermissions, requiredPermissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,logoUrl,description,url,apiKey,primaryColor,const DeepCollectionEquality().hash(requiredPermissions));

@override
String toString() {
  return 'MiniAppEntity(id: $id, name: $name, logoUrl: $logoUrl, description: $description, url: $url, apiKey: $apiKey, primaryColor: $primaryColor, requiredPermissions: $requiredPermissions)';
}


}

/// @nodoc
abstract mixin class $MiniAppEntityCopyWith<$Res>  {
  factory $MiniAppEntityCopyWith(MiniAppEntity value, $Res Function(MiniAppEntity) _then) = _$MiniAppEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String logoUrl, String description, String url, String apiKey,@ColorConverter() Color primaryColor, List<String> requiredPermissions
});




}
/// @nodoc
class _$MiniAppEntityCopyWithImpl<$Res>
    implements $MiniAppEntityCopyWith<$Res> {
  _$MiniAppEntityCopyWithImpl(this._self, this._then);

  final MiniAppEntity _self;
  final $Res Function(MiniAppEntity) _then;

/// Create a copy of MiniAppEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? logoUrl = null,Object? description = null,Object? url = null,Object? apiKey = null,Object? primaryColor = null,Object? requiredPermissions = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logoUrl: null == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,apiKey: null == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as Color,requiredPermissions: null == requiredPermissions ? _self.requiredPermissions : requiredPermissions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [MiniAppEntity].
extension MiniAppEntityPatterns on MiniAppEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MiniAppEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MiniAppEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MiniAppEntity value)  $default,){
final _that = this;
switch (_that) {
case _MiniAppEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MiniAppEntity value)?  $default,){
final _that = this;
switch (_that) {
case _MiniAppEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String logoUrl,  String description,  String url,  String apiKey, @ColorConverter()  Color primaryColor,  List<String> requiredPermissions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MiniAppEntity() when $default != null:
return $default(_that.id,_that.name,_that.logoUrl,_that.description,_that.url,_that.apiKey,_that.primaryColor,_that.requiredPermissions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String logoUrl,  String description,  String url,  String apiKey, @ColorConverter()  Color primaryColor,  List<String> requiredPermissions)  $default,) {final _that = this;
switch (_that) {
case _MiniAppEntity():
return $default(_that.id,_that.name,_that.logoUrl,_that.description,_that.url,_that.apiKey,_that.primaryColor,_that.requiredPermissions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String logoUrl,  String description,  String url,  String apiKey, @ColorConverter()  Color primaryColor,  List<String> requiredPermissions)?  $default,) {final _that = this;
switch (_that) {
case _MiniAppEntity() when $default != null:
return $default(_that.id,_that.name,_that.logoUrl,_that.description,_that.url,_that.apiKey,_that.primaryColor,_that.requiredPermissions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MiniAppEntity implements MiniAppEntity {
  const _MiniAppEntity({required this.id, required this.name, required this.logoUrl, required this.description, required this.url, required this.apiKey, @ColorConverter() required this.primaryColor, required final  List<String> requiredPermissions}): _requiredPermissions = requiredPermissions;
  factory _MiniAppEntity.fromJson(Map<String, dynamic> json) => _$MiniAppEntityFromJson(json);

@override final  String id;
@override final  String name;
@override final  String logoUrl;
@override final  String description;
@override final  String url;
// The URL to load in the WebView
@override final  String apiKey;
// The URL to load in the WebView
@override@ColorConverter() final  Color primaryColor;
 final  List<String> _requiredPermissions;
@override List<String> get requiredPermissions {
  if (_requiredPermissions is EqualUnmodifiableListView) return _requiredPermissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_requiredPermissions);
}


/// Create a copy of MiniAppEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MiniAppEntityCopyWith<_MiniAppEntity> get copyWith => __$MiniAppEntityCopyWithImpl<_MiniAppEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MiniAppEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MiniAppEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.url, url) || other.url == url)&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&const DeepCollectionEquality().equals(other._requiredPermissions, _requiredPermissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,logoUrl,description,url,apiKey,primaryColor,const DeepCollectionEquality().hash(_requiredPermissions));

@override
String toString() {
  return 'MiniAppEntity(id: $id, name: $name, logoUrl: $logoUrl, description: $description, url: $url, apiKey: $apiKey, primaryColor: $primaryColor, requiredPermissions: $requiredPermissions)';
}


}

/// @nodoc
abstract mixin class _$MiniAppEntityCopyWith<$Res> implements $MiniAppEntityCopyWith<$Res> {
  factory _$MiniAppEntityCopyWith(_MiniAppEntity value, $Res Function(_MiniAppEntity) _then) = __$MiniAppEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String logoUrl, String description, String url, String apiKey,@ColorConverter() Color primaryColor, List<String> requiredPermissions
});




}
/// @nodoc
class __$MiniAppEntityCopyWithImpl<$Res>
    implements _$MiniAppEntityCopyWith<$Res> {
  __$MiniAppEntityCopyWithImpl(this._self, this._then);

  final _MiniAppEntity _self;
  final $Res Function(_MiniAppEntity) _then;

/// Create a copy of MiniAppEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? logoUrl = null,Object? description = null,Object? url = null,Object? apiKey = null,Object? primaryColor = null,Object? requiredPermissions = null,}) {
  return _then(_MiniAppEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logoUrl: null == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,apiKey: null == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as Color,requiredPermissions: null == requiredPermissions ? _self._requiredPermissions : requiredPermissions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
