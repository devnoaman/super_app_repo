import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared/shared.dart';
import 'package:super_app_manager/super_app_manager.dart';
import 'package:super_app_mobile/features/home/presentation/token.dart';
import 'package:super_app_mobile/features/home/providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get the async state (loading, data, error)
    final miniAppsAsyncValue = ref.watch(miniAppsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Super App Home')),

      body: miniAppsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (apps) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final url = Uri.parse('https://uat.gudea.gov.iq/api/v1/auth/login');
                      final request = await HttpClient().postUrl(url);
                      request.headers.contentType = ContentType.json;
                      request.write(jsonEncode({
                        "phone": "07903974013",
                        "password": "123456789"
                      }));
                      final response = await request.close();
                      final responseBody = await response.transform(utf8.decoder).join();
                      final data = jsonDecode(responseBody);
                      
                      if (data['status'] == 'success') {
                        token = data['user']['token'];
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Token updated successfully!')),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to update token.')),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Get New Token'),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final miniApp = apps[index];
                    return MiniAppEntityCard(miniApp: miniApp);
                  },
                ),
              ),
            ],
          );
        },
      ),
      // body: Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: Wrap(
      //     spacing: 8,
      //     children: [
      //       ElevatedButton(
      //         onPressed: () async {
      //           var img = await AppOperations.openCamera();
      //           print(img);
      //         },
      //         child: Text(
      //           'open camera',
      //         ),
      //       ),
      //       ElevatedButton(onPressed: () {}, child: Text('data')),
      //     ],
      //   ),
      // ),
    );
  }
}

class MiniAppEntityCard extends StatelessWidget {
  const MiniAppEntityCard({super.key, required this.miniApp});
  final MiniAppEntity miniApp;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      color: miniApp.primaryColor.withOpacity(0.1),
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: miniApp.primaryColor,
          backgroundImage: NetworkImage(miniApp.logoUrl),
        ),
        title: Text(
          miniApp.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(miniApp.description),
        onTap: () {
          // Navigate to the host screen, passing the selected mini-app.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MiniAppHost(miniApp: miniApp),
            ),
          );
        },
      ),
    );
  }
}

class MiniAppHost extends StatelessWidget {
  const MiniAppHost({
    super.key,
    required this.miniApp,
  });

  final MiniAppEntity miniApp;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MiniAppHostScreen(
        miniApp: miniApp,
        config: AppConfig(
          userId: '123456',
          theme: 'light',
          apiEndpoint: 'apiEndpoint',
          deviceLocale: 'en',
          topSafeArea: 16,
          exchangeToken: token,
        ),
        hostScreenType: HostScreenType.embedded,
        extendBodyBehindAppBar: true,
        onPageScrolled: (deltaX, deltaY) {
          print("deltaX: $deltaX, deltaY: $deltaY");
        },

        appBarBuilder: (appData, context, isScrolled) => _MiniAppHostBar(
          appData: appData,
          isScrolled: isScrolled,
          onInfo: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (_) => _MiniAppInfoSheet(appData: appData),
            );
          },
          onClose: () => Navigator.pop(context),
        ),

        // unauthorizedScreenBuilder: (miniApp) {
        //   return Center(
        //     child: Text("Unauthorized ${miniApp.name}"),
        //   );
        // },
        // loadingScreenBuilder: () {
        //   return const Center(child: FlutterLogo());
        // },
      ),
    );
  }
}

// ─── Custom app bar ─────────────────────────────────────────────────────────
class _MiniAppHostBar extends StatelessWidget implements PreferredSizeWidget {
  const _MiniAppHostBar({
    required this.appData,
    required this.onInfo,
    required this.onClose,
    required this.isScrolled,
  });

  final MiniAppEntity appData;
  final VoidCallback onInfo;
  final VoidCallback onClose;
  final bool isScrolled;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  bool get _isDark => appData.primaryColor.computeLuminance() < 0.4;
  Color get _onColor => _isDark ? Colors.white : Colors.black87;

  @override
  Widget build(BuildContext context) {
    final accent = appData.primaryColor;
    final darkerAccent = Color.lerp(accent, Colors.black, 0.32)!;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: isScrolled ? 10 : 0,
          sigmaY: isScrolled ? 10 : 0,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: isScrolled
              ? BoxDecoration(
                  color: appData.primaryColor,
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      accent.withOpacity(0.82),
                      darkerAccent.withOpacity(0.88),
                    ],
                  ),
                  // border: Border(
                  //   bottom: BorderSide(
                  //     // color: _onColor.withOpacity(0.12),
                  //     width: 0.6,
                  //   ),
                  // ),
                )
              : null,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    // ― App logo
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.22),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                          BoxShadow(
                            color: accent.withOpacity(0.45),
                            blurRadius: 14,
                            spreadRadius: -2,
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
                                color: accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // ― Name + version
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appData.name,
                            style: TextStyle(
                              color: _onColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _onColor.withOpacity(0.55),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'v${appData.version}',
                                style: TextStyle(
                                  color: _onColor.withOpacity(0.65),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ― Info pill button (reuses existing widget)
                    _InfoIconButton(onTap: onInfo),
                    const SizedBox(width: 8),

                    // ― Close circle button
                    GestureDetector(
                      onTap: onClose,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _onColor.withOpacity(0.16),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _onColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: _onColor,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Frosted info button ────────────────────────────────────────────────────
class _InfoIconButton extends StatelessWidget {
  const _InfoIconButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.white, size: 16),
            SizedBox(width: 5),
            Text(
              'Info',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Info bottom sheet ───────────────────────────────────────────────────────
class _MiniAppInfoSheet extends StatelessWidget {
  const _MiniAppInfoSheet({required this.appData});
  final MiniAppEntity appData;

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







