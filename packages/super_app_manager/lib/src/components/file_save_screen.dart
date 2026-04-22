import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';

class FileSaveScreen extends StatefulWidget {
  const FileSaveScreen({
    super.key,
    required this.suggestedFileName,
    required this.data,
    this.accentColor,
    required this.ctx,
  });

  final String suggestedFileName;
  final File data;
  final BuildContext ctx;

  /// Optional accent — falls back to a neutral teal if not provided.
  final Color? accentColor;

  @override
  State<FileSaveScreen> createState() => _FileSaveScreenState();
}

class _FileSaveScreenState extends State<FileSaveScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _rotateController;
  late final AnimationController _pulseController;

  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  late final Animation<double> _scaleIn;
  late final Animation<double> _pulse;

  late final TextEditingController _nameController;

  _SaveState _saveState = _SaveState.idle;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.suggestedFileName,
    );

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

    _fadeIn = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
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
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ── Accent color ─────────────────────────────────────────────────────────

  Color get _accent =>
      widget.accentColor ?? const Color(0xFF1D9E75); // teal fallback

  Color get _accentDark =>
      HSLColor.fromColor(_accent).withLightness(0.28).toColor();

  Color get _accentLight => HSLColor.fromColor(
    _accent,
  ).withLightness(0.55).withSaturation(0.9).toColor();

  // ── File metadata helpers ─────────────────────────────────────────────────

  String get _extension {
    final parts = widget.suggestedFileName.split('.');
    return parts.length > 1 ? '.${parts.last.toLowerCase()}' : '';
  }

  IconData get _fileIcon {
    switch (_extension) {
      case '.pdf':
        return Iconsax.document_text;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.webp':
        return Iconsax.image;
      case '.xls':
      case '.xlsx':
        return Iconsax.document_filter;
      case '.doc':
      case '.docx':
        return Iconsax.document;
      case '.zip':
      case '.rar':
      case '.tar':
        return Iconsax.archive;
      case '.mp4':
      case '.mov':
      case '.avi':
        return Iconsax.video;
      case '.mp3':
      case '.wav':
        return Iconsax.music;
      default:
        return Iconsax.document_text_1;
    }
  }

  String get _fileSize {
    final bytes = widget.data.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ── Save action ───────────────────────────────────────────────────────────

  Future<void> _onSave() async {
    if (_saveState != _SaveState.idle) return;

    setState(() => _saveState = _SaveState.saving);

    try {
      // ── Insert your actual save logic here ───────────────────────────────
      // e.g. using path_provider + permission_handler:
      //
      // final dir = await getExternalStorageDirectory();
      // final file = File('${dir!.path}/${_nameController.text}');
      // var r = await file.writeAsBytes(widget.data.readAsBytesSync());
      // print(r.path);
      Directory? baseDir;
      if (Platform.isAndroid) {
        // Standard path: /storage/emulated/0/YourAppName
        baseDir = await getApplicationDocumentsDirectory();

        // Note: Requires manage_external_storage or specific media permissions on Android 11+
        baseDir = Directory('${baseDir.path}/files');
      } else if (Platform.isIOS) {
        // On iOS, we stay inside the sandbox but make it visible to the 'Files' app
        baseDir = await getApplicationDocumentsDirectory();
        // Optional: Create a subfolder if you want
        baseDir = Directory('${baseDir.path}/files');
      }
      // await file.writeAsBytes(base64Decode());
      // ─────────────────────────────────────────────────────────────────────
      if (baseDir != null && !await baseDir.exists()) {
        await baseDir.create(recursive: true);
      }

      final file = File('${baseDir!.path}/${_nameController.text}');
      await file.writeAsBytes(widget.data.readAsBytesSync());
      //   // Simulated async save
      //   await Future.delayed(const Duration(milliseconds: 1800));

      if (!mounted) return;
      setState(() => _saveState = _SaveState.done);

      //   await Future.delayed(const Duration(milliseconds: 800));
      //   if (!mounted) return;
      Navigator.of(context).pop(); // return true = saved
    } catch (e) {
      debugPrint("Error saving file: $e");
      if (!mounted) return;
      setState(() => _saveState = _SaveState.error);
    }
  }

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
            child: Column(
              children: [
                // ── Drag handle ──────────────────────────────────────────
                Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(
                      position: _slideUp,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                        child: Column(
                          children: [
                            // ── File icon ────────────────────────
                            ScaleTransition(
                              scale: _scaleIn,
                              child: AnimatedBuilder(
                                animation: _pulse,
                                builder: (context, _) => _FileIcon(
                                  accentColor: _accent,
                                  pulseScale: _pulse.value,
                                  size: math.min(size.width * 0.32, 130),
                                  icon: _fileIcon,
                                  saveState: _saveState,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // ── Headline ─────────────────────────
                            Text(
                              'حفظ الملف',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'راجع تفاصيل الملف واختر مكان الحفظ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.white60 : Colors.black54,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),

                            // ── File info card ────────────────────
                            _FileInfoCard(
                              fileName: widget.suggestedFileName,
                              fileSize: _fileSize,
                              extension: _extension,
                              fileIcon: _fileIcon,
                              accent: _accent,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),

                            // ── Rename card ───────────────────────
                            _RenameCard(
                              controller: _nameController,
                              accent: _accent,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 32),

                            // ── Primary CTA ───────────────────────
                            _PrimaryButton(
                              saveState: _saveState,
                              color: _accent,
                              onTap: _onSave,
                            ),
                            const SizedBox(height: 12),

                            // ── Cancel ────────────────────────────
                            _SecondaryButton(
                              label: 'إلغاء',
                              icon: Iconsax.close_circle,
                              color: _accent,
                              isDark: isDark,
                              onTap: () => Navigator.of(widget.ctx).pop(),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Save state enum
// ─────────────────────────────────────────────────────────────────────────────

enum _SaveState { idle, saving, done, error }

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
// File Icon with glow rings  (mirrors _ReasonIcon / _OrbitIcon pattern)
// ─────────────────────────────────────────────────────────────────────────────

class _FileIcon extends StatelessWidget {
  const _FileIcon({
    required this.accentColor,
    required this.pulseScale,
    required this.size,
    required this.icon,
    required this.saveState,
  });
  final Color accentColor;
  final double pulseScale;
  final double size;
  final IconData icon;
  final _SaveState saveState;

  Color get _stateColor {
    return switch (saveState) {
      _SaveState.done => Colors.green,
      _SaveState.error => Colors.red,
      _ => accentColor,
    };
  }

  IconData get _stateIcon {
    return switch (saveState) {
      _SaveState.done => Iconsax.tick_circle,
      _SaveState.error => Iconsax.close_circle,
      _SaveState.saving => Iconsax.document_download,
      _SaveState.idle => icon,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _stateColor;
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
                color: color.withOpacity(0.08 * pulseScale),
                border: Border.all(
                  color: color.withOpacity(0.15),
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
                color: color.withOpacity(0.12 * pulseScale),
              ),
            ),
          ),
          // Icon container
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.25),
                  color.withOpacity(0.08),
                ],
              ),
              border: Border.all(
                color: color.withOpacity(0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: saveState == _SaveState.saving
                  ? _SpinningDownload(
                      color: color,
                      size: size,
                      key: const ValueKey('spin'),
                    )
                  : Icon(
                      _stateIcon,
                      key: ValueKey(saveState),
                      size: size * 0.46,
                      color: color,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Spinning download indicator shown inside icon during save
class _SpinningDownload extends StatefulWidget {
  const _SpinningDownload({
    super.key,
    required this.color,
    required this.size,
  });
  final Color color;
  final double size;

  @override
  State<_SpinningDownload> createState() => _SpinningDownloadState();
}

class _SpinningDownloadState extends State<_SpinningDownload>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
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
        child: Icon(
          Iconsax.document_download,
          size: widget.size * 0.46,
          color: widget.color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// File Info Card
// ─────────────────────────────────────────────────────────────────────────────

class _FileInfoCard extends StatelessWidget {
  const _FileInfoCard({
    required this.fileName,
    required this.fileSize,
    required this.extension,
    required this.fileIcon,
    required this.accent,
    required this.isDark,
  });
  final String fileName;
  final String fileSize;
  final String extension;
  final IconData fileIcon;
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
          // File type badge
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: accent.withOpacity(0.15),
              border: Border.all(color: accent.withOpacity(0.25)),
            ),
            child: Icon(fileIcon, color: accent, size: 26),
          ),
          const SizedBox(width: 14),
          // File details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _MetaChip(
                      label: fileSize,
                      icon: Iconsax.weight,
                      accent: accent,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    if (extension.isNotEmpty)
                      _MetaChip(
                        label: extension.toUpperCase(),
                        icon: Iconsax.document_code,
                        accent: accent,
                        isDark: isDark,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withOpacity(0.3)),
            ),
            child: Text(
              'وارد',
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.icon,
    required this.accent,
    required this.isDark,
  });
  final String label;
  final IconData icon;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: accent),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rename Card
// ─────────────────────────────────────────────────────────────────────────────

class _RenameCard extends StatelessWidget {
  const _RenameCard({
    required this.controller,
    required this.accent,
    required this.isDark,
  });
  final TextEditingController controller;
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
              Icon(Iconsax.edit_2, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(
                'اسم الملف',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black54,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Text field
          TextField(
            controller: controller,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'أدخل اسم الملف',
              hintStyle: TextStyle(
                color: isDark ? Colors.white30 : Colors.black26,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Iconsax.document_text,
                color: accent.withOpacity(0.7),
                size: 18,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: accent.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.08),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: accent.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

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
                    'يمكنك تغيير اسم الملف قبل الحفظ',
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
// Primary Button  (stateful — shows saving / done states)
// ─────────────────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.saveState,
    required this.color,
    required this.onTap,
  });
  final _SaveState saveState;
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

  String get _label => switch (widget.saveState) {
    _SaveState.saving => 'جارٍ الحفظ...',
    _SaveState.done => 'تم الحفظ',
    _SaveState.error => 'حدث خطأ',
    _SaveState.idle => 'حفظ الملف',
  };

  IconData get _icon => switch (widget.saveState) {
    _SaveState.saving => Iconsax.document_download,
    _SaveState.done => Iconsax.tick_circle,
    _SaveState.error => Iconsax.close_circle,
    _SaveState.idle => Iconsax.document_download,
  };

  Color get _color => switch (widget.saveState) {
    _SaveState.done => Colors.green,
    _SaveState.error => Colors.red,
    _ => widget.color,
  };

  @override
  Widget build(BuildContext context) {
    final isActive = widget.saveState == _SaveState.idle;
    final color = _color;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: isActive ? (_) => _ctrl.reverse() : null,
        onTapUp: isActive
            ? (_) {
                _ctrl.forward();
                widget.onTap();
              }
            : null,
        onTapCancel: isActive ? () => _ctrl.forward() : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                HSLColor.fromColor(color)
                    .withLightness(
                      (HSLColor.fromColor(color).lightness - 0.12).clamp(
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
                color: color.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: widget.saveState == _SaveState.saving
                    ? _MiniSpinner(
                        key: const ValueKey('spinner'),
                        color: Colors.white,
                      )
                    : Icon(
                        _icon,
                        key: ValueKey(widget.saveState),
                        color: Colors.white,
                        size: 20,
                      ),
              ),
              const SizedBox(width: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _label,
                  key: ValueKey(_label),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
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
// Mini spinner for inside the button
// ─────────────────────────────────────────────────────────────────────────────

class _MiniSpinner extends StatefulWidget {
  const _MiniSpinner({super.key, required this.color});
  final Color color;

  @override
  State<_MiniSpinner> createState() => _MiniSpinnerState();
}

class _MiniSpinnerState extends State<_MiniSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
        child: SizedBox(
          width: 20,
          height: 20,
          child: CustomPaint(painter: _SpinnerPainter(widget.color)),
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = color.withOpacity(0.25);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;

    canvas.drawCircle(center, radius, paint);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 1.2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => old.color != color;
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
