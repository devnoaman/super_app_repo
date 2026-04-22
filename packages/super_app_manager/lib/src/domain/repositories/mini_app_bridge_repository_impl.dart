import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:super_app_common/super_app_common.dart';

import '../../data/services/permission_handler_provider.dart';
import '../../mini_app_entity/mini_app_entity.dart';
import '../../models/mini_app_status.dart';
import 'i_mini_app_bridge_repository.dart';

class MiniAppBridgeRepositoryImpl implements IMiniAppBridgeRepository {
  @override
  Future<void> initialize({
    required InAppWebViewController controller,
    required Function(MiniAppStatus verificationStatus) onVerified,
    required AppConfig config,
    required MiniAppEntity miniApp,
  }) async {
    // The valid API key is now passed from the miniApp object.
    _addConfigHandler(controller, config);

    _addVerificationHandler(controller, onVerified, miniApp.apiKey);
    for (final permission in miniApp.requiredPermissions) {
      PermissionHandlerProvider.registerHandlerForPermission(
        permission,
        controller,
      );
    }
    // _addCameraHandler(controller);
  }

  void _addVerificationHandler(
    InAppWebViewController controller,
    Function(MiniAppStatus) onVerified,
    String validApiKey, // Accepts the key as a parameter
  ) {
    controller.addJavaScriptHandler(
      handlerName: 'verifyApiKey',
      callback: (args) {
        final String receivedKey = args.isNotEmpty ? args[0] : "";
        // Verifies against the passed-in key
        onVerified(
          receivedKey == validApiKey
              ? Verified()
              : const Unauthorized(UnauthorizedReason.apiKey),
        );
      },
    );
  }

  void _addConfigHandler(
    InAppWebViewController controller,
    AppConfig config,
  ) {
    controller.addJavaScriptHandler(
      handlerName: 'getConfiguration',
      callback: (args) {
        // final config = {
        //   'userId': 'user-xyz-987',
        //   'theme': 'dark',
        //   'deviceLocale': Platform.localeName,
        // };
        return jsonEncode(config.toJson());
      },
    );
  }
}
