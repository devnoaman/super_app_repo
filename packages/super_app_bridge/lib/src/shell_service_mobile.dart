import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:super_app_common/models/app_config.dart';
import 'package:super_app_common/models/shell_event.dart';
import 'package:super_app_manager/super_app_manager.dart';

import 'shell_service_interface.dart';

ShellService getShellService({required String apiKey}) =>
    MobileShellService(apiKey: apiKey);

/// MOBILE implementation of the ShellService.
///
/// Uses [AppOperations] from `super_app_manager` to perform native actions directly.
class MobileShellService implements ShellService {
  final _eventController = StreamController<ShellEvent>.broadcast();
  final _readyCompleter = Completer<void>();

  MobileShellService({required this.apiKey}) {
    debugPrint("ShellService: Initializing with API key: $apiKey");

    // Mobile shell is ready immediately
    _readyCompleter.complete();
  }
  final String apiKey;

  @override
  Stream<ShellEvent> get events => _eventController.stream;

  @override
  Future<void> get isReady => _readyCompleter.future;

  @override
  void dispose() {
    _eventController.close();
  }

  // --- Outbound API Methods ---

  @override
  Future<void> verify() async {
    // On mobile native, we trust the mini-app or verification is handled differently.
    // For consistency with web, we could emit a success, but for now just no-op.
    debugPrint("MobileShellService: verify called (no-op)");
  }

  @override
  Future<void> requestCamera() async {
    try {
      debugPrint("MobileShellService: requesting camera...");
      final String? base64Image = await AppOperations.openCamera();
      if (base64Image != null) {
        _eventController.add(PictureTakenEvent(base64Image));
      }
    } catch (e) {
      debugPrint("MobileShellService error: $e");
      _eventController.add(ShellErrorEvent("Camera request failed", e));
    }
  }

  @override
  Future<void> requestScanner() async {
    try {
      debugPrint("MobileShellService: requesting scanner...");
      final String? code = await AppOperations.openScanner();
      if (code != null) {
        _eventController.add(ScannerResultEvent(code));
      }
    } catch (e) {
      debugPrint("MobileShellService error: $e");
      _eventController.add(ShellErrorEvent("Scanner request failed", e));
    }
  }

  @override
  Future<void> requestLocation() async {
    try {
      debugPrint("MobileShellService: requesting location...");
      final location = await AppOperations.getLocation();
      if (location != null) {
        _eventController.add(
          LocationUpdateEvent(location.latitude, location.longitude),
        );
      }
    } catch (e) {
      debugPrint("MobileShellService error: $e");
      _eventController.add(ShellErrorEvent("Location request failed", e));
    }
  }

  @override
  Future<AppConfig?> getConfiguration() async {
    try {
      debugPrint("MobileShellService: requesting configuration...");
      return await AppOperations.getConfiguration();
    } catch (e) {
      debugPrint("MobileShellService error: $e");
      return null;
    }
  }

  @override
  Future<void> launchUri(Uri uri) async {
    try {
      debugPrint("MobileShellService: requesting uri...");
      final location = await AppOperations.launchUri(uri);
      if (location != null) {
        _eventController.add(LaunchUriEvent(uri));
      }
    } catch (e) {
      debugPrint("MobileShellService error: $e");
      _eventController.add(ShellErrorEvent("Launch uri failed", e));
    }
  }
}
