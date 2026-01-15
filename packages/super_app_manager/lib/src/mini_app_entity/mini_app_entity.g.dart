// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mini_app_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MiniAppEntity _$MiniAppEntityFromJson(Map<String, dynamic> json) =>
    _MiniAppEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String,
      description: json['description'] as String,
      version: json['version'] as String,
      requiredVersion: json['requiredVersion'] as String,
      url: json['url'] as String,
      apiKey: json['apiKey'] as String,
      primaryColor: const ColorConverter().fromJson(
        json['primaryColor'] as String,
      ),
      requiredPermissions: (json['requiredPermissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MiniAppEntityToJson(_MiniAppEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logoUrl': instance.logoUrl,
      'description': instance.description,
      'version': instance.version,
      'requiredVersion': instance.requiredVersion,
      'url': instance.url,
      'apiKey': instance.apiKey,
      'primaryColor': const ColorConverter().toJson(instance.primaryColor),
      'requiredPermissions': instance.requiredPermissions,
    };
