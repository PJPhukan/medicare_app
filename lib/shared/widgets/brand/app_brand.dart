import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../layout/app_container.dart';
import '../texts/app_text.dart';

enum AppBrandLayout {
  /// Logo icon above wordmark (default).
  vertical,

  /// Logo icon and wordmark side by side.
  horizontal,

  /// Logo icon only — no wordmark.
  logoOnly,

  /// Wordmark text only — no logo icon.
  wordmarkOnly,
}

/// Unified brand widget. Use instead of any inline logo/wordmark combination.
///
/// ```dart
/// AppBrand()                                    // vertical (default)
/// AppBrand(layout: AppBrandLayout.horizontal)   // side by side
/// AppBrand(layout: AppBrandLayout.logoOnly)     // icon only
/// AppBrand(layout: AppBrandLayout.wordmarkOnly) // text only
/// AppBrand(size: 40)                            // smaller icon
/// ```
class AppBrand extends StatelessWidget {
  const AppBrand({
    super.key,
    this.layout = AppBrandLayout.vertical,
    this.size = 56,
  });

  final AppBrandLayout layout;

  /// Size of the logo square. Wordmark font scales proportionally.
  final double size;

  @override
  Widget build(BuildContext context) {
    final logo = _Logo(size: size);
    final wordmark = _Wordmark(size: size);

    return switch (layout) {
      AppBrandLayout.logoOnly     => logo,
      AppBrandLayout.wordmarkOnly => wordmark,
      AppBrandLayout.horizontal   => Row(
          mainAxisSize: MainAxisSize.min,
          children: [logo, SizedBox(width: size * 0.18), wordmark],
        ),
      AppBrandLayout.vertical     => Column(
          mainAxisSize: MainAxisSize.min,
          children: [logo, const SizedBox(height: 10), wordmark],
        ),
    };
  }
}

// ── Logo icon ─────────────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  const _Logo({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size * 0.286),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.teal, Color(0xFF00B89E)],
      ),
      shadow: [
        BoxShadow(
          color: AppColors.teal.withValues(alpha: 0.35),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(size * 0.5, size * 0.5),
        painter: _CrossPainter(),
      ),
    );
  }
}

// ── Wordmark ──────────────────────────────────────────────────────────────────

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return AppText.h2(
      AppStrings.appName,
      color: AppColors.teal,
      fontWeight: FontWeight.w800,
    );
  }
}

// ── Cross painter ─────────────────────────────────────────────────────────────

class _CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    const cw = 5.0;
    const ch = 16.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: cw, height: ch),
        const Radius.circular(2),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: ch, height: cw),
        const Radius.circular(2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CrossPainter old) => false;
}
