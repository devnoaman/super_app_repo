import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:super_app_manager/src/components/check_qr_view.dart';
import 'package:super_app_manager/src/components/get_current_location.dart';
import 'package:super_app_manager/src/framework/di_accessor_container.dart';
import 'package:super_app_manager/src/presentation/mini_app_host_screen.dart';
import 'package:super_app_manager/src/utils/extentions.dart';
import 'package:super_app_common/super_app_common.dart';

class AppOperations {
  static final ImagePicker _picker = ImagePicker();

  // Allow external app to register a navigator key for context access
  static GlobalKey<NavigatorState>? navigatorKey;

  AppOperations._();
  static Future<String?> openCamera() async {
    try {
      final XFile? imageFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 80,
      );
      if (imageFile == null) return null;
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      return base64Image;
      // controller.evaluateJavascript(source: "onPictureTaken('$base64Image')");
    } catch (e) {
      print("Failed to pick image: $e");
      return null;
    }
  }

  static Future<String?> openScanner() async {
    // Try to get context from container first (Super App environment)
    BuildContext? ctx;
    try {
      var apCtx = container.read(appCtxProvider);
      ctx = apCtx.currentState?.context;
    } catch (e) {
      // Fallback or ignore if container not set up
    }

    // Fallback to manually registered navigator key (Standalone environment)
    if (ctx == null) {
      debugPrint(
        "AppOperations: ctx from provider is null. Checking navigatorKey...",
      );
      if (navigatorKey != null) {
        debugPrint("AppOperations: navigatorKey is SET.");
        if (navigatorKey!.currentState == null) {
          debugPrint(
            "AppOperations: navigatorKey.currentState is NULL (Key not attached?)",
          );
        } else {
          debugPrint("AppOperations: navigatorKey.currentState found.");
        }
        ctx = navigatorKey!.currentContext;
        debugPrint(
          "AppOperations: ctx from navigatorKey is ${ctx != null ? 'VALID' : 'NULL'}",
        );
      } else {
        debugPrint("AppOperations: navigatorKey is NULL.");
      }
    }

    try {
      if (ctx != null) {
        var res = await showModalBottomSheet<String?>(
          isScrollControlled: true,
          isDismissible: true,
          constraints: BoxConstraints(
            minHeight: ctx.height * .9,
            maxHeight: ctx.height * .9,
          ),
          context: ctx,
          builder: (context) => CheckQrView(),
        );
        if (res != null) {
          return res;
        } else {
          // User dismissed without scanning
          return null;
        }
      } else {
        debugPrint("AppOperations: No context available for openScanner");
      }
    } catch (e) {
      debugPrint("AppOperations: openScanner error: $e");
      return null;
    }
    return null;
  }

  static Future<LatLng?> getLocation() async {
    // Try to get context from container first (Super App environment)
    BuildContext? ctx;
    try {
      var apCtx = container.read(appCtxProvider);
      ctx = apCtx.currentState?.context;
    } catch (e) {
      // Fallback or ignore
    }

    // Fallback to manually registered navigator key (Standalone environment)
    if (ctx == null && navigatorKey != null) {
      ctx = navigatorKey!.currentContext;
    }

    if (ctx != null) {
      return await Navigator.of(
        ctx,
      ).push<LatLng?>(
        MaterialPageRoute(
          builder: (context) => GetCurrentLocation(),
        ),
      );
    } else {
      debugPrint("AppOperations: No context available for getLocation");
    }
    return null;
  }

  static Future<AppConfig> getConfiguration() async {
    // Return a default configuration for mobile standalone usage
    return AppConfig(
      userId: 'mobile-user',
      theme: 'light', // Default, or checks system brightness
      apiEndpoint: 'https://api.gudea.com', // Placeholder
      deviceLocale: Platform.localeName,
    );
  }

  static Future<dynamic> launchUri(Uri uri) async {
    try {
      if (uri.toString().startsWith("http://")) {
        return await launchUrl(uri);
      } else {
        return await launchUrl(Uri.parse(uri.toString()));
      }
    } catch (e) {
      debugPrint("AppOperations: launchUri error: $e");
      return null;
    }
  }
}
