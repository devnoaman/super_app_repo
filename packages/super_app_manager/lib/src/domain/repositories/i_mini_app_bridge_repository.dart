import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:super_app_common/super_app_common.dart';

import '../../mini_app_entity/mini_app_entity.dart';
import '../../models/mini_app_status.dart';

// This is the contract that the BLoC uses.
// It defines WHAT the bridge does, not HOW it does it.
abstract class IMiniAppBridgeRepository {
  Future<void> initialize({
    required InAppWebViewController controller,
    required Function(MiniAppStatus verificationStatus) onVerified,
    required MiniAppEntity miniApp,
    required AppConfig config,
  });
}
