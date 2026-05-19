import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/auth_shell.dart';

class BiometricScreen extends StatelessWidget {
  const BiometricScreen({
    super.key,
    required this.onContinue,
    required this.onSkip,
    required this.onBack,
  });

  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textSecondary : const Color(0xFF64748B);
    final borderColor = isDark ? AppColors.dark600 : const Color(0xFFE2E8F0);
    final bgInput = isDark ? AppColors.dark700 : Colors.white;

    return AuthShell(
      showBack: true,
      onBack: onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          const AuthBrand(),
          const SizedBox(height: 32),

          Text(AppStrings.enableBiometrics,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 26, fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A202C),
                letterSpacing: -0.3,
              )),
          const SizedBox(height: 8),
          Text(AppStrings.biometricSubtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: secondaryColor)),
          const SizedBox(height: 40),

          Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.teal.withValues(alpha: 0.08),
              border: Border.all(color: AppColors.teal.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.teal.withValues(alpha: 0.10),
                  blurRadius: 32, spreadRadius: 12,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.fingerprint_rounded, size: 68, color: AppColors.teal),
            ),
          ),
          const SizedBox(height: 20),

          Text(AppStrings.touchSensor,
              style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: AppColors.teal,
              )),
          const SizedBox(height: 40),

          AuthButton(label: AppStrings.enableBiometricsBtn, onPressed: onContinue),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _GhostBtn(
                  label: AppStrings.usePassword,
                  borderColor: borderColor,
                  bgColor: bgInput,
                  textColor: secondaryColor,
                  onTap: onSkip,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GhostBtn(
                  label: AppStrings.useOtp,
                  borderColor: borderColor,
                  bgColor: bgInput,
                  textColor: secondaryColor,
                  onTap: onSkip,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          TextButton(
            onPressed: onSkip,
            child: Text(AppStrings.skipForNow,
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w500,
                  color: secondaryColor,
                )),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _GhostBtn extends StatelessWidget {
  const _GhostBtn({
    required this.label,
    required this.borderColor,
    required this.bgColor,
    required this.textColor,
    this.onTap,
  });
  final String label;
  final Color borderColor;
  final Color bgColor;
  final Color textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: textColor,
              )),
        ),
      ),
    );
  }
}
