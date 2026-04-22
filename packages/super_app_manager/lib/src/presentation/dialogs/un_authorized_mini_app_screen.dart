import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:super_app_manager/src/models/mini_app_status.dart';
import 'package:super_app_manager/super_app_manager.dart';

class UnAuthorizedMiniAppScreen extends StatefulWidget {
  const UnAuthorizedMiniAppScreen({
    super.key,
    required this.miniApp,
    required this.reason,
  });
  final MiniAppEntity miniApp;
  final UnauthorizedReason reason;

  @override
  State<UnAuthorizedMiniAppScreen> createState() =>
      _UnAuthorizedMiniAppScreenState();
}

class _UnAuthorizedMiniAppScreenState extends State<UnAuthorizedMiniAppScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;

  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  late final Animation<double> _scaleIn;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _fadeIn = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));
    _scaleIn = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  // Derive a rich accent from the mini app's primary color
  Color get _accent => widget.miniApp.primaryColor;
  Color get _accentDark =>
      HSLColor.fromColor(_accent).withLightness(0.28).toColor();
  Color get _accentLight => HSLColor.fromColor(
    _accent,
  ).withLightness(0.55).withSaturation(0.9).toColor();

  // ── Reason-driven getters ───────────────────────────────────────────────────

  IconData get _icon => switch (widget.reason) {
    UnauthorizedReason.apiKey => Iconsax.key,
    UnauthorizedReason.version => Iconsax.shield_slash,
  };

  String get _headline => switch (widget.reason) {
    UnauthorizedReason.apiKey => 'مفتاح غير صالح',
    UnauthorizedReason.version => 'غير مصرح بالوصول',
  };

  String get _subtitle => switch (widget.reason) {
    UnauthorizedReason.apiKey =>
      'لا يمكن تشغيل هذا التطبيق حالياً\nبسبب مشكلة في مصادقة المفتاح',
    UnauthorizedReason.version =>
      'لا يمكن تشغيل هذا التطبيق حالياً\nبسبب عدم التحقق من الإصدار',
  };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgTop = isDark
        ? Color.lerp(_accentDark, Colors.black, 0.6)!
        : Color.lerp(_accentLight, Colors.white, 0.55)!;
    final bgBottom = isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF0F2F5);

    return Scaffold(
      backgroundColor: bgBottom,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Animated background ────────────────────────────────────────
          _AnimatedBackground(
            topColor: bgTop,
            bottomColor: bgBottom,
            accentColor: _accent,
            rotateController: _rotateController,
          ),

          // ── Safe area content ──────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(
                      position: _slideUp,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                        child: Column(
                          children: [
                            // ── Icon ───────────────────────────────────
                            ScaleTransition(
                              scale: _scaleIn,
                              child: AnimatedBuilder(
                                animation: _pulse,
                                builder: (context, child) {
                                  return _ReasonIcon(
                                    accentColor: _accent,
                                    pulseScale: _pulse.value,
                                    size: math.min(size.width * 0.32, 130),
                                    icon: _icon,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 28),

                            // ── Headline ───────────────────────────────
                            Text(
                              _headline,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.white60 : Colors.black54,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),

                            // ── Mini app identity card ─────────────────
                            _AppInfoCard(
                              miniApp: widget.miniApp,
                              accent: _accent,
                              isDark: isDark,
                              reason: widget.reason,
                            ),
                            const SizedBox(height: 16),

                            // ── Detail card (reason-specific) ──────────
                            if (widget.reason == UnauthorizedReason.version)
                              _VersionCard(
                                currentVersion: widget.miniApp.version,
                                requiredVersion: widget.miniApp.requiredVersion,
                                accent: _accent,
                                isDark: isDark,
                              )
                            else
                              _ApiKeyCard(
                                accent: _accent,
                                isDark: isDark,
                              ),
                            const SizedBox(height: 32),

                            // ── Primary CTA ────────────────────────────
                            _PrimaryButton(
                              label: 'عودة',
                              icon: Iconsax.arrow_left_1,
                              color: _accent,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(height: 12),

                            // ── Secondary CTA ──────────────────────────
                            _SecondaryButton(
                              label: 'إرسال بلاغ',
                              icon: Iconsax.send_1,
                              color: _accent,
                              isDark: isDark,
                              onTap: () => _showReportDialog(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _ReportDialog(accent: _accent),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Mesh Background
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground({
    required this.topColor,
    required this.bottomColor,
    required this.accentColor,
    required this.rotateController,
  });
  final Color topColor;
  final Color bottomColor;
  final Color accentColor;
  final AnimationController rotateController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: rotateController,
      builder: (context, _) {
        final angle = rotateController.value * 2 * math.pi;
        return Stack(
          children: [
            // Base gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [topColor, bottomColor],
                ),
              ),
            ),
            // Rotating blob
            Positioned(
              top: -80,
              right: -60,
              child: Transform.rotate(
                angle: angle,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accentColor.withOpacity(0.18),
                        accentColor.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Second blob
            Positioned(
              bottom: 40,
              left: -40,
              child: Transform.rotate(
                angle: -angle * 0.7,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accentColor.withOpacity(0.12),
                        accentColor.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reason Icon with Glow (replaces _ShieldIcon)
// ─────────────────────────────────────────────────────────────────────────────

class _ReasonIcon extends StatelessWidget {
  const _ReasonIcon({
    required this.accentColor,
    required this.pulseScale,
    required this.size,
    required this.icon,
  });
  final Color accentColor;
  final double pulseScale;
  final double size;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 40,
      height: size + 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Transform.scale(
            scale: pulseScale,
            child: Container(
              width: size + 36,
              height: size + 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.08 * pulseScale),
                border: Border.all(
                  color: accentColor.withOpacity(0.15),
                  width: 1,
                ),
              ),
            ),
          ),
          // Middle glow ring
          Transform.scale(
            scale: pulseScale,
            child: Container(
              width: size + 18,
              height: size + 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.12 * pulseScale),
              ),
            ),
          ),
          // Icon container
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accentColor.withOpacity(0.25),
                  accentColor.withOpacity(0.08),
                ],
              ),
              border: Border.all(
                color: accentColor.withOpacity(0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: size * 0.48,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glass Button (back button)
// ─────────────────────────────────────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.06),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.15)
                : Colors.black.withOpacity(0.08),
          ),
        ),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Identity Card
// ─────────────────────────────────────────────────────────────────────────────

class _AppInfoCard extends StatelessWidget {
  const _AppInfoCard({
    required this.miniApp,
    required this.accent,
    required this.isDark,
    required this.reason,
  });
  final MiniAppEntity miniApp;
  final Color accent;
  final bool isDark;
  final UnauthorizedReason reason;

  Color get _badgeColor => switch (reason) {
    UnauthorizedReason.apiKey => Colors.red,
    UnauthorizedReason.version => Colors.orange,
  };

  String get _badgeLabel => switch (reason) {
    UnauthorizedReason.apiKey => 'خطأ مفتاح',
    UnauthorizedReason.version => 'محظور',
  };

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.75);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.06);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // App logo
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: accent.withOpacity(0.15),
              border: Border.all(color: accent.withOpacity(0.25)),
            ),
            child: miniApp.logoUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.network(
                      miniApp.logoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Iconsax.element_4,
                        color: accent,
                        size: 28,
                      ),
                    ),
                  )
                : Icon(Iconsax.element_4, color: accent, size: 28),
          ),
          const SizedBox(width: 14),
          // App details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  miniApp.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  miniApp.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _badgeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _badgeColor.withOpacity(0.3)),
            ),
            child: Text(
              _badgeLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// API Key Error Card
// ─────────────────────────────────────────────────────────────────────────────

class _ApiKeyCard extends StatelessWidget {
  const _ApiKeyCard({required this.accent, required this.isDark});
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.75);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.06);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(Iconsax.info_circle, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(
                'تفاصيل الخطأ',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black54,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Error row
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Iconsax.key, size: 15, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'مفتاح API غير صالح أو منتهي الصلاحية.\nيرجى التواصل مع مزود الخدمة.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Hint row
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Iconsax.lamp_on, size: 15, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تأكد من صلاحية مفتاح الاتصال وأعد المحاولة',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Version Comparison Card
// ─────────────────────────────────────────────────────────────────────────────

class _VersionCard extends StatelessWidget {
  const _VersionCard({
    required this.currentVersion,
    required this.requiredVersion,
    required this.accent,
    required this.isDark,
  });
  final String currentVersion;
  final String requiredVersion;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.75);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.06);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(Iconsax.info_circle, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(
                'تفاصيل الإصدار',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black54,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Current vs Required
          Row(
            children: [
              Expanded(
                child: _VersionTile(
                  label: 'الإصدار الحالي',
                  version: currentVersion,
                  icon: Iconsax.mobile,
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Iconsax.arrow_right_1,
                  color: isDark ? Colors.white30 : Colors.black26,
                  size: 18,
                ),
              ),
              Expanded(
                child: _VersionTile(
                  label: 'الإصدار المطلوب',
                  version: requiredVersion,
                  icon: Iconsax.tick_circle,
                  color: Colors.green,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Upgrade hint
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Iconsax.lamp_on, size: 15, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'يرجى تحديث التطبيق للوصول إلى هذه الخدمة',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionTile extends StatelessWidget {
  const _VersionTile({
    required this.label,
    required this.version,
    required this.icon,
    required this.color,
    required this.isDark,
  });
  final String label;
  final String version;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            version,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primary Button
// ─────────────────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.reverse(),
        onTapUp: (_) {
          _ctrl.forward();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.forward(),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.color,
                HSLColor.fromColor(widget.color)
                    .withLightness(
                      (HSLColor.fromColor(widget.color).lightness - 0.12).clamp(
                        0.0,
                        1.0,
                      ),
                    )
                    .toColor(),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Secondary Button
// ─────────────────────────────────────────────────────────────────────────────

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.07) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Report Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _ReportDialog extends StatelessWidget {
  const _ReportDialog({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.12),
              ),
              child: const Icon(
                Iconsax.tick_circle,
                color: Colors.green,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'تم إرسال البلاغ',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'تم إرسال البلاغ بنجاح.\nسنتحقق من المشكلة في أقرب وقت ممكن.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withOpacity(0.75)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'موافق',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
