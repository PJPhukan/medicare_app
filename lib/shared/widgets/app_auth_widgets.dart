import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import 'app_button.dart';

// ─── Social login button ──────────────────────────────────────────────────────

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.label,
    required this.logo,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final Widget logo;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      variant: AppButtonVariant.secondary,
      isFullWidth: true,
      isLoading: isLoading,
      onPressed: onPressed,
      icon: SizedBox(width: 20, height: 20, child: logo),
    );
  }
}

// ─── Auth divider ─────────────────────────────────────────────────────────────

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.label = 'or continue with'});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.dark600)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: AppTypography.caption),
        ),
        const Expanded(child: Divider(color: AppColors.dark600)),
      ],
    );
  }
}

// ─── Auth card wrapper ────────────────────────────────────────────────────────

class AuthCard extends StatelessWidget {
  const AuthCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.logo,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? logo;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (logo != null) ...[
            Center(child: logo!),
            const SizedBox(height: 24),
          ],
          if (title != null) ...[
            Text(title!, style: AppTypography.h1),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!, style: AppTypography.bodySm),
            ],
            const SizedBox(height: 28),
          ],
          child,
        ],
      ),
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
              Text('${AppStrings.agreeToTerms} ', style: AppTypography.bodySm),
              GestureDetector(
                onTap: onTermsTap,
                child: Text(AppStrings.termsAndConditions,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.teal,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.teal,
                  ),
                ),
              ),
              Text(' ${AppStrings.and} ', style: AppTypography.bodySm),
              GestureDetector(
                onTap: onPrivacyTap,
                child: Text(AppStrings.privacyPolicy,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.teal,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.teal,
                  ),
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
        child: Text(
          AppStrings.resendOtp,
          style: AppTypography.labelMd.copyWith(color: AppColors.teal),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Text(
      '${AppStrings.resendIn} $_remaining s',
      style: AppTypography.bodySm,
      textAlign: TextAlign.center,
    );
  }
}

// ─── App logo widget ─────────────────────────────────────────────────────────

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.teal, AppColors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppBorderRadius.lgAll,
      ),
      child: Icon(Icons.favorite_rounded, color: Colors.white, size: size * 0.48),
    );
  }
}
