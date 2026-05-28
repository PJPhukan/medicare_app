import 'package:flutter/material.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import 'app_base_button.dart';

/// Social / OAuth login buttons (Google, Apple, Facebook, GitHub, Phone).
///
/// ```dart
/// AppSocialButton.google(label: 'Continue with Google', onPressed: _googleSignIn)
/// AppSocialButton.apple(onPressed: _appleSignIn)
/// AppSocialButton.phone(onPressed: _phoneSignIn)
/// ```
class AppSocialButton extends StatefulWidget {
  const AppSocialButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.provider,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = AppButtonSize.md,
  });

  factory AppSocialButton.google({
    Key? key,
    String label = 'Continue with Google',
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
  }) =>
      AppSocialButton(
        key: key,
        label: label,
        onPressed: onPressed,
        provider: AppSocialProvider.google,
        isLoading: isLoading,
        isFullWidth: isFullWidth,
      );

  factory AppSocialButton.apple({
    Key? key,
    String label = 'Continue with Apple',
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
  }) =>
      AppSocialButton(
        key: key,
        label: label,
        onPressed: onPressed,
        provider: AppSocialProvider.apple,
        isLoading: isLoading,
        isFullWidth: isFullWidth,
      );

  factory AppSocialButton.facebook({
    Key? key,
    String label = 'Continue with Facebook',
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
  }) =>
      AppSocialButton(
        key: key,
        label: label,
        onPressed: onPressed,
        provider: AppSocialProvider.facebook,
        isLoading: isLoading,
        isFullWidth: isFullWidth,
      );

  factory AppSocialButton.github({
    Key? key,
    String label = 'Continue with GitHub',
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
  }) =>
      AppSocialButton(
        key: key,
        label: label,
        onPressed: onPressed,
        provider: AppSocialProvider.github,
        isLoading: isLoading,
        isFullWidth: isFullWidth,
      );

  factory AppSocialButton.phone({
    Key? key,
    String label = 'Continue with Phone',
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
  }) =>
      AppSocialButton(
        key: key,
        label: label,
        onPressed: onPressed,
        provider: AppSocialProvider.phone,
        isLoading: isLoading,
        isFullWidth: isFullWidth,
      );

  final String label;
  final VoidCallback onPressed;
  final AppSocialProvider provider;
  final bool isLoading;
  final bool isFullWidth;
  final AppButtonSize size;

  @override
  State<AppSocialButton> createState() => _AppSocialButtonState();
}

class _AppSocialButtonState extends State<AppSocialButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppAnimations.fast);
    _scale = Tween<double>(begin: 1.0, end: AppAnimations.pressScale).animate(
      CurvedAnimation(parent: _ctrl, curve: AppAnimations.decelerate),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final cfg     = _config(widget.provider, isDark);
    final pad     = switch (widget.size) {
      AppButtonSize.sm => const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      AppButtonSize.md => const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      AppButtonSize.lg => const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    };
    final labelStyle = AppTypography.buttonMd.copyWith(color: cfg.fg);
    final iconSize   = 20.0;

    Widget inner = DecoratedBox(
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: AppBorderRadius.lgAll,
        border: cfg.border != null
            ? Border.all(color: cfg.border!, width: 1.5)
            : null,
      ),
      child: Padding(
        padding: pad,
        child: Row(
          mainAxisSize:
              widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isLoading)
              SizedBox(
                width: iconSize,
                height: iconSize,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: cfg.fg),
              )
            else ...[
              _ProviderIcon(provider: widget.provider, size: iconSize),
              const SizedBox(width: 10),
              Flexible(
                child: Text(widget.label,
                    style: labelStyle, maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ],
        ),
      ),
    );

    if (widget.isFullWidth) {
      inner = SizedBox(width: double.infinity, child: inner);
    }

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: inner,
      ),
    );
  }

  _SocialCfg _config(AppSocialProvider p, bool isDark) => switch (p) {
        AppSocialProvider.google => _SocialCfg(
            bg: context.inputBg,
            fg: context.primaryText,
            border: context.borderCol,
          ),
        AppSocialProvider.apple => _SocialCfg(
            bg: isDark ? Colors.white : AppColors.textInverse,
            fg: isDark ? AppColors.textInverse : Colors.white,
          ),
        AppSocialProvider.facebook => _SocialCfg(
            bg: const Color(0xFF1877F2),
            fg: Colors.white,
          ),
        AppSocialProvider.github => _SocialCfg(
            bg: isDark ? const Color(0xFF24292E) : const Color(0xFF24292E),
            fg: Colors.white,
          ),
        AppSocialProvider.phone => _SocialCfg(
            bg: AppColors.teal,
            fg: Colors.white,
          ),
      };
}

// ─── Provider icon ─────────────────────────────────────────────────────────────

class _ProviderIcon extends StatelessWidget {
  const _ProviderIcon({required this.provider, required this.size});
  final AppSocialProvider provider;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (provider) {
      AppSocialProvider.google   => _GoogleIcon(size: size),
      AppSocialProvider.apple    => Icon(Icons.apple_rounded,
                                        size: size,
                                        color: isDark
                                            ? const Color(0xFF1A202C)
                                            : Colors.white),
      AppSocialProvider.facebook => Icon(Icons.facebook_rounded,
                                        size: size, color: Colors.white),
      AppSocialProvider.github   => Icon(Icons.code_rounded,
                                        size: size, color: Colors.white),
      AppSocialProvider.phone    => Icon(Icons.phone_rounded,
                                        size: size, color: Colors.white),
    };
  }
}

// Google coloured "G" icon drawn with text
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2;

    // Draw four coloured arcs approximating the Google logo
    final colors = [
      const Color(0xFF4285F4), // blue  — top
      const Color(0xFFEA4335), // red   — left
      const Color(0xFFFBBC05), // yellow— bottom
      const Color(0xFF34A853), // green — right
    ];
    final sweeps = [
      (start: -1.05, sweep: 1.57),
      (start:  0.52, sweep: 1.57),
      (start:  2.09, sweep: 1.57),
      (start:  3.66, sweep: 1.57),
    ];

    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.2
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.7),
        sweeps[i].start,
        sweeps[i].sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GooglePainter old) => false;
}

// ─── Config helpers ────────────────────────────────────────────────────────────

class _SocialCfg {
  const _SocialCfg({required this.bg, required this.fg, this.border});
  final Color bg;
  final Color fg;
  final Color? border;
}

enum AppSocialProvider { google, apple, facebook, github, phone }
