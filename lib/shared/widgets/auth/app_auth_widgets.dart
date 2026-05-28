import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extensions.dart';
import '../texts/app_text.dart';

// ─── Auth divider ─────────────────────────────────────────────────────────────

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.label = 'or continue with'});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: context.dividerCol)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: AppText.caption(label),
        ),
        Expanded(child: Divider(color: context.dividerCol)),
      ],
    );
  }
}

// ─── Terms agreement row ──────────────────────────────────────────────────────

class TermsRow extends StatelessWidget {
  const TermsRow({
    super.key,
    required this.agreed,
    required this.onChanged,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  final bool agreed;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24, height: 24,
          child: Checkbox(value: agreed, onChanged: onChanged),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            children: [
              AppText.bodySm('${AppStrings.agreeToTerms} '),
              GestureDetector(
                onTap: onTermsTap,
                child: AppText.bodySm(
                  AppStrings.termsAndConditions,
                  color: AppColors.teal,
                ),
              ),
              AppText.bodySm(' ${AppStrings.and} '),
              GestureDetector(
                onTap: onPrivacyTap,
                child: AppText.bodySm(
                  AppStrings.privacyPolicy,
                  color: AppColors.teal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── OTP resend timer ─────────────────────────────────────────────────────────

class OtpResendTimer extends StatefulWidget {
  const OtpResendTimer({
    super.key,
    required this.onResend,
    this.seconds = 30,
  });

  final VoidCallback onResend;
  final int seconds;

  @override
  State<OtpResendTimer> createState() => _OtpResendTimerState();
}

class _OtpResendTimerState extends State<OtpResendTimer> {
  late int _remaining;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _tick();
  }

  void _tick() async {
    while (_remaining > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _remaining--);
    }
    if (mounted) setState(() => _canResend = true);
  }

  void _resend() {
    setState(() { _remaining = widget.seconds; _canResend = false; });
    widget.onResend();
    _tick();
  }

  @override
  Widget build(BuildContext context) {
    if (_canResend) {
      return GestureDetector(
        onTap: _resend,
        child: AppText.labelMd(
          AppStrings.resendOtp,
          color: AppColors.teal,
          textAlign: TextAlign.center,
        ),
      );
    }
    return AppText.bodySm(
      '${AppStrings.resendIn} $_remaining s',
      textAlign: TextAlign.center,
    );
  }
}

// ─── Brand icons for social login ─────────────────────────────────────────────

class AuthGoogleIcon extends StatelessWidget {
  const AuthGoogleIcon({super.key});
  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(18, 18),
        painter: _GoogleIconPainter(),
      );
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    void arc(double startAngle, double sweepAngle, Color color) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.72),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.28
          ..strokeCap = StrokeCap.butt,
      );
    }

    final colors = [
      const Color(0xFFEA4335),
      const Color(0xFFFBBC05),
      const Color(0xFF34A853),
      const Color(0xFF4285F4),
    ];
    for (int i = 0; i < 4; i++) {
      arc(-3.14159 / 2 + i * 3.14159 / 2, 3.14159 / 2 - 0.05, colors[i]);
    }
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.72),
      0, 3.14159 / 2, false,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.22,
    );
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
  bool shouldRepaint(_GoogleIconPainter old) => false;
}

class AuthAppleIcon extends StatelessWidget {
  const AuthAppleIcon({super.key});
  @override
  Widget build(BuildContext context) => Icon(
        Icons.apple,
        size: 20,
        color: context.isDark ? Colors.white : const Color(0xFF1A202C),
      );
}
