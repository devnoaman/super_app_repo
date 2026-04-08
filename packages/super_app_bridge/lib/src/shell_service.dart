import 'package:super_app_bridge/src/shell_service_interface.dart';
import 'package:super_app_bridge/src/shell_service_mobile.dart'
    if (dart.library.js_interop) 'package:super_app_bridge/src/shell_service_web.dart'
    as impl;

export 'package:super_app_bridge/src/shell_service_interface.dart';

/// Returns the correct platform-specific implementation of [ShellService].
///
/// On Web, returns [WebShellService].
/// On Mobile, returns [MobileShellService] (stub).
ShellService getShellService({required String apiKey}) =>
    impl.getShellService(apiKey: apiKey);

/// Legacy factory function. Use [getShellService] instead.
ShellService getPlatformShellService({required String apiKey}) {
  return impl.getShellService(apiKey: apiKey);
}
