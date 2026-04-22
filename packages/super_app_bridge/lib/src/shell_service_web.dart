import 'dart:async';
import 'dart:io';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/material.dart';
import 'package:super_app_bridge/src/shell_service_interface.dart';
import 'package:super_app_common/super_app_common.dart';

import 'dart:convert';

import 'package:web/web.dart' as html;

import 'package:flutter/foundation.dart'; // For debugPrint

ShellService getShellService({required String apiKey}) =>
    WebShellService(apiKey: apiKey);
// JS interop for the callHandler function (remains top-level)
@JS('window.flutter_inappwebview.callHandler')
external JSPromise _callHandler(JSString handlerName, JSAny? args1);

/// A service to communicate with the Super App Shell.
///
/// This service encapsulates bridge initialization, handles inbound event
/// streaming, and provides methods for outbound API calls.
class WebShellService implements ShellService {
  String _apiKey = "";

  /// Manages the inbound event stream from the native shell.
  final _eventController = StreamController<ShellEvent>.broadcast();

  /// Completes when the JS bridge is initialized and ready.
  final _readyCompleter = Completer<void>();

  /// Public stream of events for widgets to listen to.
  @override
  Stream<ShellEvent> get events => _eventController.stream;

  /// A future that completes when the bridge is ready.
  /// API methods await this before executing.
  @override
  Future<void> get isReady => _readyCompleter.future;

  /// Creates the service and begins initialization.
  WebShellService({required this.apiKey}) {
    debugPrint("ShellService: Initializing with API key: $apiKey");
    _apiKey = apiKey;
    _initialize();
  }
  final String apiKey;

  /// Checks if the JS bridge is ready, or waits for the ready event.
  void _initialize() {
    // Check if the bridge object already exists
    if (html.window.hasProperty(EventsHandler.handlerName.toJS).toDart) {
      debugPrint("ShellService: Bridge found immediately.");
      _registerJsHandlers();
      _readyCompleter.complete();
    } else {
      debugPrint(
        "ShellService: Bridge not found, awaiting platform ready event...",
      );
      // Listen for the 'flutterInAppWebViewPlatformReady' event
      html.window.addEventListener(
        EventsHandler.platformReady,
        ((html.Event event) {
          debugPrint("ShellService: Platform ready event received.");
          _registerJsHandlers();
          _readyCompleter.complete();
        }).toJS,
      );
    }
  }

  /// Registers all the JS functions that the native shell can call.
  /// These functions pipe data into the event stream.
  void _registerJsHandlers() {
    try {
      // --- Handler for Picture Taken ---
      globalContext.setProperty(
        EventsHandler.onPictureTaken.toJS,
        ((JSString base64) {
          _eventController.add(PictureTakenEvent(base64.toDart));
        }).toJS,
      );

      // --- Handler for Scanner Result ---
      globalContext.setProperty(
        EventsHandler.onScanResult.toJS,
        ((JSString scanData) {
          _eventController.add(ScannerResultEvent(scanData.toDart));
        }).toJS,
      );
      // --- Handler for File Save Result ---
      globalContext.setProperty(
        EventsHandler.onFileSaveResult.toJS,
        ((JSString result) {
          _eventController.add(FileSaveResultEvent(result.toDart));
        }).toJS,
      );

      // --- Handler for Location Update ---
      globalContext.setProperty(
        EventsHandler.onLocationUpdate.toJS,
        ((JSString jsonLocation) {
          debugPrint(jsonLocation.toString());
          try {
            final data =
                jsonDecode(jsonLocation.toDart) as Map<String, dynamic>;
            _eventController.add(LocationUpdateEvent(data['lat'], data['lng']));
          } catch (e) {
            _eventController.add(
              ShellErrorEvent("Failed to parse location data", e),
            );
          }
        }).toJS,
      );
      // --- Handler for Launch URI ---
      globalContext.setProperty(
        EventsHandler.onLaunchUriCall.toJS,
        ((JSString uri) {
          _eventController.add(LaunchUriEvent(Uri.parse(uri.toDart)));
        }).toJS,
      );

      debugPrint("ShellService: All JS handlers registered.");
    } catch (e) {
      debugPrint("ShellService: Critical error registering JS handlers: $e");
      _eventController.addError(
        ShellErrorEvent("Failed to register JS handlers", e),
      );
    }
  }

  /// Cleans up resources, primarily the stream controller.
  @override
  void dispose() {
    _eventController.close();
  }

  // --- Outbound API Methods ---

  /// Verifies the mini-app with the shell using a secret API key.
  @override
  Future<void> verify() async {
    await isReady; // Ensures bridge is ready before calling
    try {
      debugPrint("ShellService: Sending API key...");
      await _callHandler(EventsHandler.verifyApiKey.toJS, _apiKey.toJS).toDart;
    } catch (e) {
      debugPrint("Error: Could not send API key. $e");
      _eventController.add(ShellErrorEvent("API key verification failed", e));
    }
  }

  /// Requests the native shell to open the camera.
  @override
  Future<void> requestCamera() async {
    await isReady;
    try {
      debugPrint("ShellService: Requesting camera...");
      await _callHandler(
        EventsHandler.openCmera.toJS,
        'from-flutter-web'.toJS,
      ).toDart;
    } catch (e) {
      debugPrint("Error: Could not request camera. $e");
      _eventController.add(ShellErrorEvent("Camera request failed", e));
    }
  }

  /// Requests the native shell to open the scanner.
  @override
  Future<void> requestScanner() async {
    await isReady;
    try {
      debugPrint("ShellService: Requesting scanner...");
      await _callHandler(
        EventsHandler.openScanner.toJS,
        'from-flutter-web'.toJS,
      ).toDart;
    } catch (e) {
      debugPrint("Error: Could not request scanner. $e");
      _eventController.add(ShellErrorEvent("Scanner request failed", e));
    }
  }

  /// Requests the native shell to open the scanner.
  @override
  Future<void> requestLocation() async {
    await isReady;
    try {
      debugPrint("ShellService: Requesting location...");
      await _callHandler(
        EventsHandler.openLocationPicker.toJS,
        'from-flutter-web'.toJS,
      ).toDart;
    } catch (e) {
      debugPrint("Error: Could not request scanner. $e");
      _eventController.add(
        ShellErrorEvent("Location Picker request failed", e),
      );
    }
  }

  @override
  Future<void> requestFileSave(String suggestedFileName, Uint8List data) async {
    await isReady;
    try {
      debugPrint("ShellService: Requesting file save ...");
      await _callHandler(
        EventsHandler.onFileSave.toJS,
        jsonEncode({"fileName": suggestedFileName, "data": data}).toJS,
      ).toDart;
    } catch (e) {
      debugPrint("Error: Could not request file save. $e");
      _eventController.add(ShellErrorEvent("File save request failed", e));
    }
  }

  /// Fetches the [AppConfig] from the native shell.
  @override
  Future<AppConfig?> getConfiguration() async {
    await isReady;
    try {
      debugPrint("ShellService: Requesting configuration...");
      final JSAny? promiseResult = await _callHandler(
        EventsHandler.getConfiguration.toJS,
        null,
      ).toDart;

      if (promiseResult == null) {
        debugPrint("ShellService: getConfiguration received null result.");
        return null;
      }

      final String jsonString = (promiseResult as JSString).toDart;
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      //  _eventController.add(ShellErrorEvent("Get configuration failed", e));
      return AppConfig.fromJson(jsonMap);
    } catch (e) {
      debugPrint("Error: Could not get configuration from shell: $e");
      _eventController.add(ShellErrorEvent("Get configuration failed", e));
      return null;
    }
  }

  @override
  Future<void> launchUri(Uri uri) async {
    await isReady;
    try {
      debugPrint("ShellService: Launching URI...");
      await _callHandler(
        EventsHandler.onLaunchUriCall.toJS,
        uri.toString().toJS,
      ).toDart;
    } catch (e) {
      debugPrint("Error: Could not launch URI. $e");
      _eventController.add(ShellErrorEvent("URI launch failed", e));
    }
  }

  @override
  Future<void> requestShare(
    String text,
    String? mimeType,
    String? subject,
    String? fileName,
    Uint8List? file,
  ) async {
    await isReady;
    try {
      debugPrint("ShellService: Requesting share...");
      await _callHandler(
        EventsHandler.onShare.toJS,
        jsonEncode({
          "text": text,
          "mimeType": mimeType,
          "subject": subject,
          "fileName": fileName,
          "file": file,
        }).toJS,
      ).toDart;
    } catch (e) {
      debugPrint("Error: Could not request share. $e");
      _eventController.add(ShellErrorEvent("Share request failed", e));
    }
  }
}
