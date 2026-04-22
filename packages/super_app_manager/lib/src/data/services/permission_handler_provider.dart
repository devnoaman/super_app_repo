import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:super_app_common/events_handler.dart';

import 'app_operations.dart';

/// A dedicated class to provide and register JavaScript handlers based on permission strings.
class PermissionHandlerProvider {
  // A single instance of the picker for all handlers to use.

  // The private map that associates a permission string with its handler registration method.
  static final Map<String, Function(InAppWebViewController)> _handlerMap = {
    'camera': _addCameraHandler,
    'scan': _addScannerHandler,
    'location': _addLocationHandler,
    'uri': _addUriHandler,
    'fileSave': _addFileSaveHandler,
    'share': _addShareHandler,
    // Future permissions can be added here, e.g.:

    // Future handlers can be added here, e.g.:
    // 'location': _addLocationHandler,
  };

  /// Looks up a permission string and registers the corresponding JavaScript handler.
  static void registerHandlerForPermission(
    String permission,
    InAppWebViewController controller,
  ) {
    if (_handlerMap.containsKey(permission)) {
      print("Registering handler for required permission: '$permission'");
      // Find the correct registration function in the map and execute it.
      _handlerMap[permission]!(controller);
    } else {
      print("Warning: No handler implemented for permission '$permission'");
    }
  }

  /// The private implementation for the 'camera' permission handler.
  static void _addCameraHandler(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: EventsHandler.openCmera,
      callback: (args) async {
        var image = await AppOperations.openCamera();
        if (image != null) {
          controller.evaluateJavascript(
            source: "${EventsHandler.onPictureTaken}('$image')",
          );
        }
      },
    );
  }

  static void _addScannerHandler(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: EventsHandler.openScanner,
      callback: (args) async {
        var data = await AppOperations.openScanner();
        if (data != null) {
          controller.evaluateJavascript(
            source: "${EventsHandler.onScanResult}('$data')",
          );
        }
      },
    );
  }

  static void _addLocationHandler(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: EventsHandler.openLocationPicker,
      callback: (args) async {
        var loc = await AppOperations.getLocation();
        if (loc != null) {
          final locationData = {
            'lat': loc.latitude,
            'lng': loc.longitude,
          };
          final jsonString = jsonEncode(locationData);
          controller.evaluateJavascript(
            source: "${EventsHandler.onLocationUpdate}('$jsonString')",
          );
        }
      },
    );
  }

  static void _addUriHandler(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: EventsHandler.onLaunchUriCall,
      callback: (args) async {
        log("Uri: ${args}");
        final uri = args.isNotEmpty ? args[0] : "";
        var result = await AppOperations.launchUri(Uri.parse(uri));
        if (result != null) {
          final jsonString = jsonEncode(result);
          controller.evaluateJavascript(
            source: "${EventsHandler.onLaunchUriResult}('$jsonString')",
          );
        }
      },
    );
  }

  static void _addFileSaveHandler(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: EventsHandler.onFileSave,
      callback: (args) async {
        log("File Save Request: ${args}");
        final data = args.isNotEmpty
            ? jsonDecode(args[0]) as Map<String, dynamic>
            : null;
        // file from uint8list
        if (data == null) {
          log("File save error: No data provided");
          controller.evaluateJavascript(
            source:
                "${EventsHandler.onFileSaveResult}('error: No data provided')",
          );
          return;
        }
        var ddata = data["data"] as List<dynamic>;
        final Uint8List file = Uint8List.fromList(
          ddata.map((e) => e as int).toList(),
        );
        final String fileName = data["fileName"] ?? "file";
        try {
          await AppOperations.saveFile(fileName, file);
          controller.evaluateJavascript(
            source: "${EventsHandler.onFileSaveResult}('success')",
          );
        } catch (e) {
          log("File save error: $e");
          controller.evaluateJavascript(
            source: "${EventsHandler.onFileSaveResult}('error: $e')",
          );
        }
      },
    );
  }

  static void _addShareHandler(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: EventsHandler.onShare,
      callback: (args) async {
        log("Share Request: ${args}");
        final data = args.isNotEmpty
            ? jsonDecode(args[0]) as Map<String, dynamic>
            : null;
        if (data == null) {
          log("Share error: No data provided");
          controller.evaluateJavascript(
            source:
                "${EventsHandler.onShareResult}('error: No data provided')",
          );
          return;
        }
        final String text = data["text"] ?? "";
        final String? mimeType = data["mimeType"];
        final String? subject = data["subject"];
        final String? fileName = data["fileName"];
        final Uint8List? file = data["file"] != null
            ? Uint8List.fromList(
                (data["file"] as List<dynamic>).map((e) => e as int).toList(),
              )
            : null;
        try {
          await AppOperations.share(text, mimeType, subject, fileName, file);
          controller.evaluateJavascript(
            source: "${EventsHandler.onShareResult}('success')",
          );
        } catch (e) {
          log("Share error: $e");
          controller.evaluateJavascript(
            source: "${EventsHandler.onShareResult}('error: $e')",
          );
        }
      },
    );
  }
}
