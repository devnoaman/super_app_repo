// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mini_app_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MiniAppEntity _$MiniAppEntityFromJson(Map<String, dynamic> json) =>
    _MiniAppEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
      description: json['description'] as String?,
      version: json['version'] as String,
      requiredVersion: json['required_version'] as String,
      url: json['url'] as String,
      apiKey: json['api_key'] as String,
      primaryColor: const ColorConverter().fromJson(
        json['primary_color'] as String,
      ),
      requiredPermissions: (json['required_permissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MiniAppEntityToJson(_MiniAppEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo_url': instance.logoUrl,
      'description': instance.description,
      'version': instance.version,
      'required_version': instance.requiredVersion,
      'url': instance.url,
      'api_key': instance.apiKey,
      'primary_color': const ColorConverter().toJson(instance.primaryColor),
      'required_permissions': instance.requiredPermissions,
    };
