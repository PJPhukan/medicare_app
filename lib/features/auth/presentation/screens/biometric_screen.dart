import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/auth_shell.dart';

class BiometricScreen extends ConsumerStatefulWidget {
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
  ConsumerState<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends ConsumerState<BiometricScreen> {
  bool _checking = true;
  bool _available = false;
  bool _enabling = false;
  List<BiometricType> _types = [];

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final svc = ref.read(biometricServiceProvider);
    final available = await svc.isAvailable();
    final types = available ? await svc.availableTypes() : <BiometricType>[];
    if (mounted) {
      setState(() {
        _available = available;
        _types = types;
        _checking = false;
      });
    }
  }

  Future<void> _enable() async {
    setState(() => _enabling = true);
    final svc = ref.read(biometricServiceProvider);
    final ok = await svc.authenticate(
      reason: AppStrings.biometricAuthReason,
    );
    if (!mounted) return;
    if (ok) {
      await svc.setEnabled(true);
      widget.onContinue();
    } else {
      setState(() => _enabling = false);
      AppSnackbar.error(context, AppStrings.biometricAuthFailed);
    }
  }

  Future<void> _skip() async {
    await ref.read(biometricServiceProvider).setEnabled(false);
    widget.onSkip();
  }

  IconData get _biometricIcon {
    if (_types.contains(BiometricType.face)) return Icons.face_rounded;
    if (_types.contains(BiometricType.iris)) return Icons.remove_red_eye_rounded;
    return Icons.fingerprint_rounded;
  }

  String get _biometricLabel {
    if (_types.contains(BiometricType.face)) return AppStrings.biometricFaceId;
    if (_types.contains(BiometricType.iris)) return AppStrings.biometricIris;
    return AppStrings.biometricFingerprint;
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      showBack: true,
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          const AppBrand(),
          const SizedBox(height: 32),

          AppText.h1(AppStrings.enableBiometrics, fontWeight: FontWeight.w800),
          const SizedBox(height: 8),
          AppText.bodyMd(
            _checking
                ? AppStrings.biometricChecking
                : _available
                    ? AppStrings.biometricSubtitle
                    : AppStrings.biometricNotAvailable,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          AnimatedOpacity(
            opacity: _checking ? 0.4 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (_available ? AppColors.teal : AppColors.textHint)
                    .withValues(alpha: 0.08),
                border: Border.all(
                  color: (_available ? AppColors.teal : AppColors.textHint)
                      .withValues(alpha: 0.25),
                ),
                boxShadow: _available
                    ? [BoxShadow(
                        color: AppColors.teal.withValues(alpha: 0.10),
                        blurRadius: 32, spreadRadius: 12,
                      )]
                    : null,
              ),
              child: Center(
                child: _checking
                    ? const CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.teal)
                    : Icon(
                        _biometricIcon, size: 68,
                        color: _available ? AppColors.teal : AppColors.textHint,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (!_checking)
            AppText.labelMd(
              _available ? _biometricLabel : AppStrings.biometricNotAvailableTag,
              color: _available ? AppColors.teal : AppColors.textHint,
            ),
          const SizedBox(height: 40),

          if (_available)
            AuthButton(
              label: _enabling ? AppStrings.biometricVerifying : AppStrings.enableBiometricsBtn,
              loading: _enabling,
              onPressed: _enabling ? null : _enable,
            ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  label: AppStrings.usePassword,
                  isFullWidth: true,
                  onPressed: _skip,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton.secondary(
                  label: AppStrings.useOtp,
                  isFullWidth: true,
                  onPressed: _skip,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          AppButton.ghost(
            label: AppStrings.skipForNow,
            onPressed: _skip,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
