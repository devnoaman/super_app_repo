// The screen now takes the MiniApp as a parameter.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared/shared.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:super_app_common/models/app_config.dart';
import 'package:super_app_manager/src/framework/di_accessor_container.dart';
import 'package:super_app_manager/src/presentation/dialogs/un_authrized_mini_app_screen.dart';

import '../mini_app_entity/mini_app_entity.dart';
import '../providers/mini_app_host_provider.dart';
import 'package:watcher/watcher.dart';

final appCtxProvider = Provider<GlobalKey<ScaffoldState>>((ref) {
  return GlobalKey<ScaffoldState>();
});

enum HostScreenType {
  fullScreen,
  embedded,
}

class MiniAppHostScreen extends ConsumerStatefulWidget {
  final MiniAppEntity miniApp;
  final HostScreenType hostScreenType;
  const MiniAppHostScreen({
    super.key,
    required this.miniApp,
    required this.hostScreenType,
  });

  @override
  ConsumerState<MiniAppHostScreen> createState() => _MiniAppHostScreenState();
}

class _MiniAppHostScreenState extends ConsumerState<MiniAppHostScreen> {
  InAppWebViewController? _webViewController;
  // For debouncing (to prevent multiple reloads on one save)
  Timer? _reloadTimer;

  // File watcher subscription
  StreamSubscription<WatchEvent>? _watcherSubscription;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // 5. Clean up
    _reloadTimer?.cancel();
    _watcherSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We pass the miniApp object to our provider family.
    final asyncState = ref.watch(miniAppHostProvider(widget.miniApp));
    final appKey = container.read(appCtxProvider);
    final notifier = ref.read(miniAppHostProvider(widget.miniApp).notifier);
    var size = MediaQuery.sizeOf(context);

    return UncontrolledProviderScope(
      container: container,
      child: asyncState.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) =>
            Scaffold(body: Center(child: Text('Error: $err'))),
        data: (state) {
          return PopScope(
            canPop: !state.canGoBack,
            onPopInvokedWithResult: (bool didPop, result) async {
              // If the pop was prevented (didPop is false), it means the webview can go back,
              // so we command the webview to navigate back.
              if (didPop) {
                return;
              }

              _webViewController?.goBack();
            },
            child: Scaffold(
              key: appKey,
              appBar: widget.hostScreenType == HostScreenType.fullScreen
                  ? null
                  : AppBar(
                      title: Text(state.miniApp.name),
                      backgroundColor: state.miniApp.primaryColor,
                      leadingWidth: 100,
                      leading: Center(
                        child: TextButton.icon(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              state.miniApp.primaryColor == Colors.white
                                  ? Colors.red.withAlpha(20)
                                  : Colors.white,
                            ),
                            foregroundColor: WidgetStatePropertyAll(Colors.red),
                          ),

                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          label: Text('اغلاق'),
                          icon: Icon(Icons.close),
                        ),
                      ),
                      actions: [
                        CustomPopup(
                          // backgroundColor: Colors.red,
                          barrierColor: state.miniApp.primaryColor.withAlpha(
                            75,
                          ),
                          content: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: size.width * .4,
                              // maxHeight: size.width*.4,
                              minWidth: size.width * .4,
                              maxWidth: size.width * .4,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  onTap: () {
                                    _webViewController?.reload();
                                  },
                                  leading: Icon(Icons.refresh),
                                  title: Text('reload'),
                                ),
                                ListTile(
                                  onTap: () {
                                    // _webViewController?.reload();
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      builder: (context) => AboutAppDialog(
                                        miniApp: widget.miniApp,
                                      ),
                                    );
                                  },
                                  leading: Icon(Icons.perm_device_info_rounded),
                                  title: Text('about app'),
                                ),
                              ],
                            ),
                          ),

                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(Icons.info_outline),
                          ),
                        ),
                      ],
                    ),
              body: Stack(
                children: [
                  Opacity(
                    opacity: state.status == MiniAppStatus.verified ? 1.0 : 0.0,
                    child: InAppWebView(
                      // key: UniqueKey(),
                      initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true,
                        cacheMode: kDebugMode
                            ? CacheMode.LOAD_NO_CACHE
                            : CacheMode.LOAD_DEFAULT,
                      ),
                      initialUrlRequest: URLRequest(
                        url: WebUri(state.miniApp.url),
                      ),
                      onWebViewCreated: (controller) {
                        // var view = View.of(context);
                        Locale deviceLocale = Localizations.localeOf(context);

                        _webViewController = controller;

                        notifier.initializeBridge(
                          controller,
                          AppConfig(
                            userId: '123456',
                            theme: 'dark',
                            apiEndpoint: 'apiEndpoint',
                            deviceLocale: deviceLocale.languageCode,
                          ),
                        );
                      },
                      onUpdateVisitedHistory:
                          (controller, url, isReload) async {
                            final canGoBack = await controller.canGoBack();
                            notifier.updateCanGoBack(canGoBack);
                            // canWebViewGoBack = canGoBack;
                          },
                      onLoadStop: (controller, url) {
                        // notifier.loadCompleted();
                      },
                      onReceivedError: (controller, request, error) {
                        notifier.loadFailed(error.description);
                      },
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: 1,
                    duration: Durations.medium2,
                    child: _buildStatusOverlay(
                      state.status,
                      widget.miniApp,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusOverlay(MiniAppStatus status, MiniAppEntity miniApp) {
    switch (status) {
      case MiniAppStatus.loading:
        return const Center(child: Text("Loading..."));
      case MiniAppStatus.verifying:
        return const Center(child: Text("Verifying..."));
      case MiniAppStatus.unauthorized:
        return UnAuthrizedMiniAppScreen(
          miniApp: miniApp,
        );
      case MiniAppStatus.error:
        return const Center(child: Text("Failed to Load Mini-App"));
      case MiniAppStatus.verified:
        return Container();
    }
  }
}

class AboutAppDialog extends StatelessWidget {
  const AboutAppDialog({super.key, required this.miniApp});
  final MiniAppEntity miniApp;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);

    return Center(
      child: Card(
        child: SizedBox(
          width: size.width * .6,
          height: size.width * .6,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(12),

                  child: Image.network(miniApp.logoUrl, width: size.width * .2),
                ),
                Text(miniApp.name),
                Text(miniApp.description),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
