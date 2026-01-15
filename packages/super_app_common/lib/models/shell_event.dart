/// Base class for all events coming from the native shell.
sealed class ShellEvent {
  const ShellEvent();
}

/// Event for when a picture is taken.
class PictureTakenEvent extends ShellEvent {
  /// The base66-encoded image data.
  final String base64Data;
  PictureTakenEvent(this.base64Data);
}

/// Event for when the scanner gets a result.
class ScannerResultEvent extends ShellEvent {
  /// The string data from the scanner (e.g., QR code content).
  final String scanData;
  ScannerResultEvent(this.scanData);
}

/// Event for when location is received.
class LocationUpdateEvent extends ShellEvent {
  final double latitude;
  final double longitude;
  LocationUpdateEvent(this.latitude, this.longitude);
}

/// Event for when a URI is launched.
class LaunchUriEvent extends ShellEvent {
  final Uri uri;
  LaunchUriEvent(this.uri);
}

/// Event for when a non-fatal error occurs in the bridge.
class ShellErrorEvent extends ShellEvent {
  final String message;
  final Object? error;
  ShellErrorEvent(this.message, [this.error]);

  @override
  String toString() => 'ShellErrorEvent: $message ${error ?? ''}';
}
