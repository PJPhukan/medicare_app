import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Shared shell ─────────────────────────────────────────────────────────────

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.child,
    this.onBack,
    this.showBack = false,
  });

  final Widget child;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.dark900 : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Subtle teal glow top-center
          Positioned(
            top: 0, left: 0, right: 0,
            height: 300,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    AppColors.teal.withValues(alpha: isDark ? 0.07 : 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                if (showBack)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: onBack,
                          icon: Icon(Icons.arrow_back_rounded, size: 16,
                              color: isDark ? AppColors.textHint : const Color(0xFF94A3B8)),
                          label: Text(
                            AppStrings.back,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textHint : const Color(0xFF94A3B8),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: child,
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

// ─── Brand logo + wordmark ────────────────────────────────────────────────────

class AuthBrand extends StatelessWidget {
  const AuthBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo mark
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.teal, Color(0xFF00B89E)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.teal.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(child: _CrossIcon()),
        ),
        const SizedBox(height: 10),
        Text(
          AppStrings.appName,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.teal,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _CrossIcon extends StatelessWidget {
  const _CrossIcon();
  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(28, 28),
        painter: _CrossPainter(),
      );
}

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

// ─── Gradient CTA button ──────────────────────────────────────────────────────

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
    this.loadingLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && !loading;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled ? 1.0 : 0.5,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF67E8F9), AppColors.teal],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.teal.withValues(alpha: 0.32),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: const Color(0xFF041226),
                      ),
                    )
                  : Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF041226),
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Divider ─────────────────────────────────────────────────────────────────

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.label = 'or continue with'});
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? AppColors.dark600 : const Color(0xFFE2E8F0);
    final textColor = isDark ? AppColors.textHint : const Color(0xFF94A3B8);

    return Row(
      children: [
        Expanded(child: Divider(color: lineColor, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(child: Divider(color: lineColor, height: 1)),
      ],
    );
  }
}

// ─── Social buttons (Google + Apple) ─────────────────────────────────────────

class SocialButtons extends StatelessWidget {
  const SocialButtons({
    super.key,
    this.onGoogle,
    this.onApple,
    this.loading = false,
  });

  final VoidCallback? onGoogle;
  final VoidCallback? onApple;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SocialBtn(label: 'Google', icon: _googleIcon, onTap: loading ? null : onGoogle)),
        const SizedBox(width: 12),
        Expanded(child: _SocialBtn(label: 'Apple', icon: _appleIcon, onTap: loading ? null : onApple)),
      ],
    );
  }

  static const _googleIcon = '''<svg>'''; // placeholder — drawn via CustomPaint below
  static const _appleIcon = '''<svg>''';
}

class _SocialBtn extends StatelessWidget {
  const _SocialBtn({required this.label, required this.icon, this.onTap});
  final String label;
  final String icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.dark600 : const Color(0xFFE2E8F0);
    final bgColor = isDark ? AppColors.dark700 : Colors.white;
    final textColor = isDark ? AppColors.textPrimary : const Color(0xFF1A202C);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (label == 'Google') const _GoogleIcon() else const _AppleIcon(),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();
  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(18, 18),
        painter: _GooglePainter(),
      );
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    void arc(double startAngle, double sweepAngle, Color color) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.28
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.72),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    // Simplified Google G - just draw a colorful circle divided into quadrants
    final colors = [
      const Color(0xFFEA4335), // red top-right
      const Color(0xFFFBBC05), // yellow bottom-left
      const Color(0xFF34A853), // green bottom-right
      const Color(0xFF4285F4), // blue top-left
    ];
    for (int i = 0; i < 4; i++) {
      arc(
        -3.14159 / 2 + i * 3.14159 / 2,
        3.14159 / 2 - 0.05,
        colors[i],
      );
    }
    // White cutout for G shape effect - just overlay smaller white arc
    final cut = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.72),
      0,
      3.14159 / 2,
      false,
      cut,
    );
    // Crossbar
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r * 0.72, cy),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = size.width * 0.26
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GooglePainter old) => false;
}

class _AppleIcon extends StatelessWidget {
  const _AppleIcon();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Icon(
      Icons.apple,
      size: 20,
      color: isDark ? Colors.white : const Color(0xFF1A202C),
    );
  }
}

// ─── Auth input field ─────────────────────────────────────────────────────────

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.hint,
    this.label,
    this.keyboardType,
    this.obscureText = false,
    this.error,
    this.suffix,
    this.prefix,
    this.autofocus = false,
    this.onChanged,
    this.inputFormatters,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.style,
  });

  final TextEditingController controller;
  final String hint;
  final String? label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? error;
  final Widget? suffix;
  final Widget? prefix;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final List<dynamic>? inputFormatters;
  final int? maxLength;
  final TextAlign textAlign;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = error != null
        ? AppColors.error
        : isDark ? AppColors.dark600 : const Color(0xFFE2E8F0);
    final focusBorderColor = error != null ? AppColors.error : AppColors.teal;
    final bg = isDark ? AppColors.dark700 : Colors.white;
    final textColor = isDark ? AppColors.textPrimary : const Color(0xFF1A202C);
    final hintColor = isDark ? AppColors.textHint : const Color(0xFF94A3B8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          autofocus: autofocus,
          textAlign: textAlign,
          maxLength: maxLength,
          onChanged: onChanged,
          style: style ?? GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 15,
              color: hintColor,
            ),
            filled: true,
            fillColor: bg,
            counterText: '',
            prefixIcon: prefix,
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: focusBorderColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error!,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Step indicator ───────────────────────────────────────────────────────────

class AuthStepper extends StatelessWidget {
  const AuthStepper({super.key, required this.steps, required this.current});
  final List<String> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIndex = i ~/ 2;
            final done = stepIndex < current;
            return Expanded(
              child: Container(
                height: 1.5,
                color: done
                    ? AppColors.teal.withValues(alpha: 0.6)
                    : isDark ? AppColors.dark600 : const Color(0xFFE2E8F0),
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final isActive = stepIndex == current;
          final isDone = stepIndex < current;
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? AppColors.teal
                      : isActive
                          ? AppColors.teal.withValues(alpha: 0.15)
                          : isDark ? AppColors.dark700 : const Color(0xFFF1F5F9),
                  border: Border.all(
                    color: isActive || isDone
                        ? AppColors.teal
                        : isDark ? AppColors.dark600 : const Color(0xFFE2E8F0),
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                      : Text(
                          '${stepIndex + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? AppColors.teal
                                : isDark ? AppColors.textHint : const Color(0xFF94A3B8),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex],
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? AppColors.teal
                      : isDark ? AppColors.textHint : const Color(0xFF94A3B8),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
