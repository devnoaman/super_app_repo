class ShellApiException implements Exception {
  final String message;
  final dynamic originalException;
  ShellApiException(this.message, [this.originalException]);

  @override
  String toString() =>
      'ShellApiException: $message (Original: $originalException)';
}
