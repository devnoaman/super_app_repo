import 'package:flutter/material.dart';
import 'package:super_app_manager/super_app_manager.dart';

enum HostScreenType {
  fullScreen,
  embedded,
}

typedef AppBarBuilder =
    PreferredSizeWidget Function(
      MiniAppEntity appData,
      BuildContext context,
    );

typedef LoadingScreenBuilder = Widget Function();
typedef ErrorScreenBuilder =
    Widget Function(Object error, StackTrace stackTrace);
typedef UnauthorizedScreenBuilder = Widget Function(MiniAppEntity miniApp);
