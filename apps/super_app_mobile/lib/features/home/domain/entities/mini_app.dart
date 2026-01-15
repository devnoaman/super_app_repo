// import 'package:shared/shared.dart';

import 'package:super_app_manager/super_app_manager.dart';

abstract class IHomeRepository {
  Future<List<MiniAppEntity>> getAvailableMiniApps();
}
