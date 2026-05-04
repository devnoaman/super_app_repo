// The screen now takes the MiniApp as a parameter.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared/shared.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:super_app_common/models/app_config.dart';
import 'package:super_app_manager/src/framework/di_accessor_container.dart';
import 'package:super_app_manager/src/models/mini_app_status.dart';
import 'package:super_app_manager/src/presentation/dialogs/loading_mini_app_screen.dart';
import 'package:super_app_manager/src/presentation/dialogs/un_authorized_mini_app_screen.dart';
import 'package:super_app_manager/src/utils/extentions.dart';
import 'package:super_app_manager/src/utils/web_user_events.dart';

import '../mini_app_entity/mini_app_entity.dart';
import '../providers/mini_app_host_provider.dart';
import 'package:watcher/watcher.dart';

import '../typedefs/host_screen_typedefs.dart';
import 'dialogs/failed_load_mini_app.dart';

final appCtxProvider = Provider<GlobalKey<ScaffoldState>>((ref) {
  return GlobalKey<ScaffoldState>();
});

class MiniAppHostScreen extends StatefulHookConsumerWidget {
  final MiniAppEntity miniApp;
  final LoadingScreenBuilder? loadingScreenBuilder;
  final ErrorScreenBuilder? errorScreenBuilder;
  final UnauthorizedScreenBuilder? unauthorizedScreenBuilder;
  final AppBarBuilder? appBarBuilder;
  final HostScreenType hostScreenType;
  final bool extendBodyBehindAppBar;
  final AppConfig config;

  /// Called on every scroll event detected inside the mini-app page.
  final OnPageScrolledCallback? onPageScrolled;

  const MiniAppHostScreen({
    super.key,
    required this.miniApp,
    required this.hostScreenType,
    this.loadingScreenBuilder,
    this.errorScreenBuilder,
    this.unauthorizedScreenBuilder,
    this.appBarBuilder,
    this.extendBodyBehindAppBar = false,
    this.onPageScrolled,
    required this.config,
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
    final isScrolled = useState(false);

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
              extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
              appBar: widget.hostScreenType == HostScreenType.fullScreen
                  ? null
                  : widget.appBarBuilder?.call(
                          state.miniApp,
                          context,
                          isScrolled.value,
                          () {
                            showModalBottomSheet(
                              context: context,
                              isDismissible: true,
                              isScrollControlled: true,
                              builder: (context) => _MiniAppInfoSheet(
                                appData: state.miniApp,
                                onReload: () {
                                  _webViewController?.reload();
                                },
                              ),

                              // AboutAppDialog(
                              //   miniApp: widget.miniApp,
                              // ),
                            );
                          },
                        ) ??
                        AppBar(
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
                                foregroundColor: WidgetStatePropertyAll(
                                  Colors.red,
                                ),
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
                              barrierColor: state.miniApp.primaryColor
                                  .withAlpha(75),
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
                                        Navigator.of(context).pop();
                                        showDialog(
                                          context: context,
                                          builder: (context) => Material(
                                            color: Colors.transparent,
                                            child: _MiniAppInfoSheet(
                                              appData: state.miniApp,
                                              onReload: () {
                                                _webViewController?.reload();
                                              },
                                            ),
                                          ),

                                          // AboutAppDialog(
                                          //   miniApp: widget.miniApp,
                                          // ),
                                        );
                                      },
                                      leading: Icon(
                                        Icons.perm_device_info_rounded,
                                      ),
                                      title: Text('about app'),
                                    ),
                                  ],
                                ),
                              ),

                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Icon(Icons.info_outline),
                              ),
                            ),
                          ],
                        ),
              body: Stack(
                children: [
                  // state.status == MiniAppStatus.verified
                  // ?
                  Opacity(
                    // opacity: state.status == Verified() ? 1.0 : 0.0,
                    opacity: 1,
                    child: InAppWebView(
                      // key: UniqueKey(),
                      // onScrollChanged: (controller, x, y) {
                      //   print('onScrollChanged: $x, $y');
                      // },
                      initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true,
                        cacheMode:
                            // kDebugMode
                            // ?
                            CacheMode.LOAD_NO_CACHE,
                        //     :
                        // CacheMode.LOAD_DEFAULT,
                      ),
                      // 1. INJECT THE JAVASCRIPT FIX
                      initialUserScripts: WebUserEvents.all,

                      initialUrlRequest: URLRequest(
                        url: WebUri(state.miniApp.url),
                      ),
                      onConsoleMessage: (controller, message) {
                        // print("message" + message.toString());
                      },
                      onWebViewCreated: (controller) {
                        // var view = View.of(context);
                        Locale deviceLocale = Localizations.localeOf(context);

                        _webViewController = controller;

                        // Register the scroll handler injected by WebUserEvents.
                        // Fires for every touchmove / wheel event inside the page.
                        if (widget.onPageScrolled != null) {
                          controller.addJavaScriptHandler(
                            handlerName: 'onScroll',
                            callback: (args) {
                              if (args.isEmpty) return;
                              final data = args[0] as Map<dynamic, dynamic>;
                              final dx =
                                  (data['deltaX'] as num?)?.toDouble() ?? 0;
                              final dy =
                                  (data['deltaY'] as num?)?.toDouble() ?? 0;
                              widget.onPageScrolled!(dx, dy);
                              if (dy > 0) {
                                isScrolled.value = true;
                              } else {
                                isScrolled.value = false;
                              }
                            },
                          );
                        }

                        notifier.initializeBridge(controller, widget.config);
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
                    // opacity: state.status == Verified() ? 1.0 : 0.0,
                    duration: Durations.medium2,
                    child: _buildStatusOverlay(state.status, widget.miniApp),
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
      case Unauthorized():
        return widget.unauthorizedScreenBuilder?.call(miniApp) ??
            UnAuthorizedMiniAppScreen(miniApp: miniApp, reason: status.reason);
      case Loading():
        return widget.loadingScreenBuilder?.call() ??
            LoadingMiniAppScreen(miniApp: miniApp);
      case Verifying():
        return const Center(child: Text("Verifying..."));

      case Error():
        return FailedToLoadMiniAppScreen(
          miniApp: miniApp,
          reason: MiniAppFailureReason.unknown,
        );
      case Verified():
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

// ─── Info bottom sheet ───────────────────────────────────────────────────────
class _MiniAppInfoSheet extends StatelessWidget {
  const _MiniAppInfoSheet({
    required this.appData,
    required this.onReload,
  });
  final MiniAppEntity appData;
  final VoidCallback onReload;

  bool get _isDarkColor => appData.primaryColor.computeLuminance() < 0.4;
  Color get _onColor => _isDarkColor ? Colors.white : Colors.black87;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.scaffoldBackgroundColor;
    final accent = appData.primaryColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Container(
            color: bg,
            child: CustomScrollView(
              controller: controller,
              slivers: [
                // ── Gradient hero header ────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent,
                          Color.lerp(accent, Colors.black, 0.28)!,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        // drag handle
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: _onColor.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // logo with glow shadow
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 24,
                                spreadRadius: 2,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: accent.withOpacity(0.5),
                                blurRadius: 32,
                                spreadRadius: -4,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              appData.logoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  appData.name[0],
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: accent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // name
                        Text(
                          appData.name,
                          style: TextStyle(
                            color: _onColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // version pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _onColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _onColor.withOpacity(0.25),
                            ),
                          ),
                          child: Text(
                            'v${appData.version}',
                            style: TextStyle(
                              color: _onColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),

                // ── Body content ────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // stat cards row
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.verified_rounded,
                              label: 'Version',
                              value: appData.version,
                              color: accent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.system_update_alt_rounded,
                              label: 'Min. Required',
                              value: appData.requiredVersion,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // about section
                      const _SectionLabel('About'),
                      const SizedBox(height: 10),
                      Text(
                        appData.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.65,
                          color: theme.colorScheme.onSurface.withOpacity(0.78),
                        ),
                      ),

                      // permissions section
                      if (appData.requiredPermissions.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        const _SectionLabel('Required Permissions'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: appData.requiredPermissions
                              .map(
                                (p) => _PermissionChip(
                                  permission: p,
                                  color: accent,
                                ),
                              )
                              .toList(),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // ── Launch CTA ────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accent,
                                Color.lerp(accent, Colors.black, 0.22)!,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(0.38),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => Navigator.pop(context),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.rocket_launch_rounded,
                                      color: _isDarkColor
                                          ? Colors.white
                                          : Colors.black87,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Got it',
                                      style: TextStyle(
                                        color: _isDarkColor
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      8.hGap,
                      //  Reload CTA
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: accent),
                            // gradient: LinearGradient(
                            //   colors: [
                            //     accent,
                            //     // Color.lerp(accent, Colors.black, 0.22)!,
                            //   ],
                            // ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(0.38),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                Navigator.pop(context);
                                onReload.call();
                              },
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.replay_outlined,
                                      color: _isDarkColor
                                          ? Colors.white
                                          : Colors.black87,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Reload',
                                      style: TextStyle(
                                        color: _isDarkColor
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Stat card ───────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.55),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ───────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
      ),
    );
  }
}

// ─── Permission chip ─────────────────────────────────────────────────────────
class _PermissionChip extends StatelessWidget {
  const _PermissionChip({required this.permission, required this.color});
  final String permission;
  final Color color;

  IconData _icon() {
    final p = permission.toLowerCase();
    if (p.contains('camera')) return Icons.camera_alt_rounded;
    if (p.contains('location')) return Icons.location_on_rounded;
    if (p.contains('mic') || p.contains('audio')) return Icons.mic_rounded;
    if (p.contains('storage') || p.contains('file'))
      return Icons.folder_rounded;
    if (p.contains('contact')) return Icons.contacts_rounded;
    if (p.contains('notif')) return Icons.notifications_rounded;
    if (p.contains('bluetooth')) return Icons.bluetooth_rounded;
    if (p.contains('network') || p.contains('internet')) {
      return Icons.wifi_rounded;
    }
    return Icons.shield_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(), size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            permission,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
