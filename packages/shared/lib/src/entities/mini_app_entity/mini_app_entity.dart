
import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'mini_app_entity.freezed.dart';
part 'mini_app_entity.g.dart';

@freezed
abstract class MiniAppEntity with _$MiniAppEntity {
  const factory MiniAppEntity({
    required String id,
    required String name,
    required String logoUrl,
    required String description,
    required String url, // The URL to load in the WebView
    required String apiKey, // The URL to load in the WebView
    @ColorConverter() required Color primaryColor,
    required List<String> requiredPermissions,
  }) = _MiniAppEntity;

  factory MiniAppEntity.fromJson(Map<String, dynamic> json) => _$MiniAppEntityFromJson(json);
}

// Helper to convert hex string color from JSON to a Color object.
class ColorConverter implements JsonConverter<Color, String> {
  const ColorConverter();
   
  @override
  Color fromJson(String json) {
    return Color(int.parse(json.replaceAll('#', '0xFF')));
  }

  @override
  String toJson(Color object) {
    return '#${object.value.toRadixString(16).substring(2)}';
  }
}
