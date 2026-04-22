// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppConfig _$AppConfigFromJson(Map<String, dynamic> json) => _AppConfig(
  userId: json['userId'] as String,
  theme: json['theme'] as String? ?? "dark",
  apiEndpoint: json['apiEndpoint'] as String,
  deviceLocale: json['deviceLocale'] as String? ?? "en_US",
  topSafeArea: (json['topSafeArea'] as num?)?.toDouble(),
  exchangeToken: json['exchangeToken'] as String,
);

Map<String, dynamic> _$AppConfigToJson(_AppConfig instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'theme': instance.theme,
      'apiEndpoint': instance.apiEndpoint,
      'deviceLocale': instance.deviceLocale,
      'topSafeArea': instance.topSafeArea,
      'exchangeToken': instance.exchangeToken,
    };
