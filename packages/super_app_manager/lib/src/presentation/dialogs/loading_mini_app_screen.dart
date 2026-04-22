import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:super_app_manager/super_app_manager.dart';

class LoadingMiniAppScreen extends StatefulWidget {
  const LoadingMiniAppScreen({
    super.key,
    required this.miniApp,
  });
  final MiniAppEntity miniApp;

  @override
  State<LoadingMiniAppScreen> createState() => _LoadingMiniAppScreenState();
}

class _LoadingMiniAppScreenState extends State<LoadingMiniAppScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _rotateController;
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;
  late final AnimationController _dotsController;

  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  late final Animation<double> _scaleIn;
  late final Animation<double> _pulse;
  late final Animation<double> _shimmer;
  late final Animation<double> _spin;

  // Loading steps shown below the card
  final List<_LoadStep> _steps = const [
    _LoadStep(label: 'جارٍ التحقق من الهوية', icon: Iconsax.shield_tick),
    _LoadStep(label: 'جارٍ تحميل الموارد', icon: Iconsax.document_download),
    _LoadStep(label: 'جارٍ تهيئة البيئة', icon: Iconsax.setting_2),
    _LoadStep(label: 'جارٍ الاتصال بالخادم', icon: Iconsax.wifi),
  ];

  int _activeStep = 0;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _fadeIn = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideUp =
        Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
        );
    _scaleIn = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );
    _pulse = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _shimmer = _shimmerController;
    _spin = Tween<double>(begin: 0, end: 1).animate(_rotateController);

    _entryController.forward();

    // Cycle through steps
    _startStepCycle();
  }

  void _startStepCycle() {
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      var nextStep = (_activeStep + 1);
      if (nextStep >= _steps.length) {
        return;
      }
      setState(() => _activeStep = nextStep);
      _startStepCycle();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  Color get _accent => widget.miniApp.primaryColor;
  Color get _accentDark =>
      HSLColor.fromColor(_accent).withLightness(0.28).toColor();
  Color get _accentLight => HSLColor.fromColor(
    _accent,
  ).withLightness(0.55).withSaturation(0.9).toColor();

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
          // ── Animated background ──────────────────────────────────────
          _AnimatedBackground(
            topColor: bgTop,
            bottomColor: bgBottom,
            accentColor: _accent,
            rotateController: _rotateController,
          ),

          // ── Content ──────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  child: Column(
                    children: [
                      // ── Spinning orbit icon ──────────────────────
                      ScaleTransition(
                        scale: _scaleIn,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _pulseController,
                            _rotateController,
                          ]),
                          builder: (context, _) {
                            return _OrbitIcon(
                              accentColor: _accent,
                              pulseScale: _pulse.value,
                              spinValue: _spin.value,
                              size: math.min(size.width * 0.32, 130),
                              logoUrl: widget.miniApp.logoUrl,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── App name + "جارٍ التحميل" ────────────────
                      Text(
                        widget.miniApp.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      _AnimatedDotsLabel(
                        accentColor: _accent,
                        controller: _dotsController,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 28),

                      // ── App identity card ────────────────────────
                      _AppInfoCard(
                        miniApp: widget.miniApp,
                        accent: _accent,
                        isDark: isDark,
                        shimmer: _shimmer,
                      ),
                      const SizedBox(height: 16),

                      // ── Progress bar card ────────────────────────
                      _ProgressCard(
                        accent: _accent,
                        isDark: isDark,
                        shimmer: _shimmer,
                        steps: _steps,
                        activeStep: _activeStep,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Mesh Background  (identical pattern to UnAuthrized screen)
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
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [topColor, bottomColor],
                ),
              ),
            ),
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
// Orbit Icon  — app logo in center, spinning arc around it
// ─────────────────────────────────────────────────────────────────────────────

class _OrbitIcon extends StatelessWidget {
  const _OrbitIcon({
    required this.accentColor,
    required this.pulseScale,
    required this.spinValue,
    required this.size,
    required this.logoUrl,
  });
  final Color accentColor;
  final double pulseScale;
  final double spinValue;
  final double size;
  final String logoUrl;

  @override
  Widget build(BuildContext context) {
    final ringSize = size + 36;
    return SizedBox(
      width: ringSize + 8,
      height: ringSize + 8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow pulse
          Transform.scale(
            scale: pulseScale,
            child: Container(
              width: ringSize,
              height: ringSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.08 * pulseScale),
                border: Border.all(
                  color: accentColor.withOpacity(0.13),
                  width: 1,
                ),
              ),
            ),
          ),

          // Spinning dashed arc (custom painter)
          Transform.rotate(
            angle: spinValue * 2 * math.pi,
            child: CustomPaint(
              size: Size(ringSize, ringSize),
              painter: _ArcPainter(color: accentColor),
            ),
          ),

          // Inner glow circle
          Container(
            width: size + 10,
            height: size + 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withOpacity(0.10 * pulseScale),
            ),
          ),

          // App logo / icon container
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
            child: ClipOval(
              child: logoUrl.isNotEmpty
                  ? Image.network(
                      logoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Iconsax.element_4,
                        color: accentColor,
                        size: size * 0.42,
                      ),
                    )
                  : Icon(
                      Iconsax.element_4,
                      color: accentColor,
                      size: size * 0.42,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Arc painter — spinning partial arc with dot at tip
// ─────────────────────────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Arc track (faint)
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = color.withOpacity(0.15),
    );

    // Sweeping arc
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 1.5,
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.9),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 1.5,
      false,
      arcPaint,
    );

    // Glowing dot at arc tip
    final tipAngle = -math.pi / 2 + math.pi * 1.5;
    final tipX = center.dx + radius * math.cos(tipAngle);
    final tipY = center.dy + radius * math.sin(tipAngle);

    canvas.drawCircle(
      Offset(tipX, tipY),
      4,
      Paint()..color = color.withOpacity(0.9),
    );
    canvas.drawCircle(
      Offset(tipX, tipY),
      7,
      Paint()..color = color.withOpacity(0.25),
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated "جارٍ التحميل ..." dots label
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedDotsLabel extends StatelessWidget {
  const _AnimatedDotsLabel({
    required this.accentColor,
    required this.controller,
    required this.isDark,
  });
  final Color accentColor;
  final AnimationController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'جارٍ التحميل',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black45,
                height: 1.5,
              ),
            ),
            const SizedBox(width: 4),
            ...List.generate(3, (i) {
              final delay = i / 3;
              final raw = ((t - delay) % 1.0 + 1.0) % 1.0;
              final opacity = math.sin(raw * math.pi).clamp(0.2, 1.0);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Identity Card  (shimmer skeleton on description)
// ─────────────────────────────────────────────────────────────────────────────

class _AppInfoCard extends StatelessWidget {
  const _AppInfoCard({
    required this.miniApp,
    required this.accent,
    required this.isDark,
    required this.shimmer,
  });
  final MiniAppEntity miniApp;
  final Color accent;
  final bool isDark;
  final Animation<double> shimmer;

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
                      errorBuilder: (_, __, ___) =>
                          Icon(Iconsax.element_4, color: accent, size: 28),
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
                const SizedBox(height: 6),
                // Shimmer skeleton lines
                AnimatedBuilder(
                  animation: shimmer,
                  builder: (context, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBar(
                        width: 160,
                        height: 9,
                        progress: shimmer.value,
                        accent: accent,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 5),
                      _ShimmerBar(
                        width: 100,
                        height: 9,
                        progress: shimmer.value,
                        accent: accent,
                        isDark: isDark,
                        delay: 0.2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Loading badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withOpacity(0.3)),
            ),
            child: Text(
              'تحميل',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer bar
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerBar extends StatelessWidget {
  const _ShimmerBar({
    required this.width,
    required this.height,
    required this.progress,
    required this.accent,
    required this.isDark,
    this.delay = 0.0,
  });
  final double width;
  final double height;
  final double progress;
  final Color accent;
  final bool isDark;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final p = ((progress - delay) % 1.0 + 1.0) % 1.0;
    final shimmerX = Tween<double>(begin: -1.0, end: 2.0).transform(p);

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(6),
        ),
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(shimmerX - 0.5, 0),
            end: Alignment(shimmerX + 0.5, 0),
            colors: [
              Colors.transparent,
              accent.withOpacity(0.45),
              Colors.transparent,
            ],
          ).createShader(bounds),
          blendMode: BlendMode.srcATop,
          child: Container(
            color: isDark
                ? Colors.white.withOpacity(0.15)
                : Colors.black.withOpacity(0.12),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress Steps Card
// ─────────────────────────────────────────────────────────────────────────────

class _LoadStep {
  const _LoadStep({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.accent,
    required this.isDark,
    required this.shimmer,
    required this.steps,
    required this.activeStep,
  });
  final Color accent;
  final bool isDark;
  final Animation<double> shimmer;
  final List<_LoadStep> steps;
  final int activeStep;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.75);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.06);

    // progress fraction: steps completed / total
    final progress = (activeStep + 1) / steps.length;

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
          // Header
          Row(
            children: [
              Icon(Iconsax.refresh, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(
                'تقدم التحميل',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black54,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Shimmer progress bar
          AnimatedBuilder(
            animation: shimmer,
            builder: (context, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 6,
                  width: double.infinity,
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.06),
                  child: AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    widthFactor: progress,
                    alignment: AlignmentDirectional.centerStart,
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        final p = ((shimmer.value - 0.0) % 1.0 + 1.0) % 1.0;
                        final sx = Tween<double>(
                          begin: -1.0,
                          end: 2.0,
                        ).transform(p);
                        return LinearGradient(
                          begin: Alignment(sx - 0.6, 0),
                          end: Alignment(sx + 0.6, 0),
                          colors: [
                            accent,
                            Color.lerp(accent, Colors.white, 0.45)!,
                            accent,
                          ],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: Container(color: accent),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),

          // Steps list
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final isDone = i < activeStep;
            final isActive = i == activeStep;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? accent.withOpacity(0.10)
                      : isDone
                      ? Colors.green.withOpacity(0.06)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? accent.withOpacity(0.25)
                        : isDone
                        ? Colors.green.withOpacity(0.2)
                        : (isDark
                              ? Colors.white.withOpacity(0.06)
                              : Colors.black.withOpacity(0.05)),
                  ),
                ),
                child: Row(
                  children: [
                    // State icon
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isDone
                          ? const Icon(
                              Iconsax.tick_circle,
                              key: ValueKey('done'),
                              size: 16,
                              color: Colors.green,
                            )
                          : isActive
                          ? _SpinningIcon(
                              key: const ValueKey('active'),
                              icon: step.icon,
                              color: accent,
                              controller: null,
                            )
                          : Icon(
                              step.icon,
                              key: const ValueKey('pending'),
                              size: 16,
                              color: isDark ? Colors.white24 : Colors.black26,
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        step.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isActive
                              ? (isDark ? Colors.white : Colors.black87)
                              : isDone
                              ? Colors.green
                              : (isDark ? Colors.white38 : Colors.black38),
                        ),
                      ),
                    ),
                    if (isActive)
                      _PulseDot(color: accent)
                    else if (isDone)
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Spinning icon (active step indicator)
// ─────────────────────────────────────────────────────────────────────────────

class _SpinningIcon extends StatefulWidget {
  const _SpinningIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.controller,
  });
  final IconData icon;
  final Color color;
  final AnimationController? controller;

  @override
  State<_SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<_SpinningIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.rotate(
        angle: _ctrl.value * 2 * math.pi,
        child: Icon(widget.icon, size: 16, color: widget.color),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pulsing dot (active step end indicator)
// ─────────────────────────────────────────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color});
  final Color color;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
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
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
        ),
      ),
    );
  }
}
