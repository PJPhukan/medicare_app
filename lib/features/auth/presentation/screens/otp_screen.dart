import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_shell.dart';
import 'auth_flow.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    required this.draft,
    required this.onBack,
    this.onVerified,
    this.purpose = 'LOGIN',
    this.verifyWithApi = true,
    this.onOtpCollected,
  });

  final AuthDraft draft;
  final VoidCallback onBack;
  final VoidCallback? onVerified;
  final String purpose;
  final bool verifyWithApi;
  final ValueChanged<String>? onOtpCollected;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _otp = '';

  Future<void> _verify() async {
    if (_otp.length != 6) return;
    try {
      widget.onOtpCollected?.call(_otp);
      if (widget.verifyWithApi) {
        await ref.read(authProvider.notifier).verifyOtp(
          identifier: widget.draft.identifier,
          otp: _otp,
        );
      }
      widget.onVerified?.call();
    } catch (_) {}
  }

  Future<void> _resend() async {
    setState(() => _otp = '');
    try {
      await ref.read(authProvider.notifier).sendOtp(
        identifier: widget.draft.identifier,
        purpose: widget.purpose,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final authState  = ref.watch(authProvider);
    final isLoading  = authState.isLoading;
    final apiError   = authState.error;
    final identifier = widget.draft.identifier.isNotEmpty
        ? widget.draft.identifier
        : 'your number';

    return AuthShell(
      leading: AppBarLeading.back,
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Center(child: AppBrand()),
          const SizedBox(height: 32),

          Center(
            child: Column(
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.teal.withValues(alpha: 0.10),
                    border: Border.all(color: AppColors.teal.withValues(alpha: 0.25)),
                  ),
                  child: const Center(
                    child: Icon(Icons.shield_rounded, size: 34, color: AppColors.teal),
                  ),
                ),
                const SizedBox(height: 20),
                AppText.h1(AppStrings.verifyIdentity, fontWeight: FontWeight.w800),
                const SizedBox(height: 8),
                Builder(builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(text: '${AppStrings.otpSentMessage}\n'),
                        TextSpan(
                          text: identifier,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 36),

          AppOtpField(
            length: 6,
            errorText: apiError,
            onChanged: (v) => setState(() => _otp = v),
            onCompleted: (v) {
              setState(() => _otp = v);
              _verify();
            },
          ),

          const SizedBox(height: 32),

          AuthButton(
            label: AppStrings.verify,
            enabled: _otp.length == 6 && !isLoading,
            loading: isLoading,
            onPressed: _verify,
          ),

          const SizedBox(height: 20),

          Center(
            child: OtpResendTimer(
              onResend: _resend,
              seconds: 30,
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
