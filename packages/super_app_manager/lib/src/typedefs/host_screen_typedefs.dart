import 'package:flutter/material.dart';
import 'package:super_app_manager/super_app_manager.dart';

enum HostScreenType { fullScreen, embedded }

typedef AppBarBuilder =
    PreferredSizeWidget Function(
      MiniAppEntity appData,
      BuildContext context,
      bool isScrolled,
      VoidCallback onInfo,
    );

typedef LoadingScreenBuilder = Widget Function();
typedef ErrorScreenBuilder =
    Widget Function(Object error, StackTrace stackTrace);
typedef UnauthorizedScreenBuilder = Widget Function(MiniAppEntity miniApp);

/// Callback fired whenever the mini-app page is scrolled.
/// [deltaX] / [deltaY] — raw scroll delta since the last event (px, touch or wheel).
typedef OnPageScrolledCallback = void Function(double deltaX, double deltaY);
