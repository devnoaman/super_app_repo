import 'dart:async';
import 'package:super_app_common/super_app_common.dart';

/// The abstract interface for the Shell Service.
///
/// Contains all the methods and streams that any platform-specific
/// implementation must provide.
abstract class ShellService {
  /// Public stream of events for widgets to listen to.
  Stream<ShellEvent> get events;

  /// A future that completes when the bridge is ready.
  Future<void> get isReady;

  /// Cleans up resources.
  void dispose();

  /// Verifies the mini-app with the shell.
  Future<void> verify();

  /// Requests the native shell to open the camera.
  Future<void> requestCamera();

  /// Requests the native shell to open the scanner.
  Future<void> requestScanner();

  /// Requests the native shell to open the location picker.
  Future<void> requestLocation();

  /// Fetches the [AppConfig] from the native shell.
  Future<AppConfig?> getConfiguration();

  /// Launches a URI in the native shell.
  Future<void> launchUri(Uri uri);
}
