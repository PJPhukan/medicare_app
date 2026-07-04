import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_shell.dart';
import '../widgets/password_strength_bar.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.identifier,
    required this.otp,
    required this.onReset,
    required this.onBack,
  });

  final String identifier;
  final String otp;
  final VoidCallback onReset;
  final VoidCallback onBack;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _newPassCtrl     = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  String? _newPassError;
  String? _matchError;

  @override
  void dispose() {
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _newPassCtrl.text.isNotEmpty && _confirmPassCtrl.text.isNotEmpty;

  Future<void> _reset() async {
    final passErr = Validators.password(_newPassCtrl.text);
    if (passErr != null) { setState(() { _newPassError = passErr; }); return; }
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      setState(() => _matchError = AppStrings.passwordsDoNotMatch2);
      return;
    }
    try {
      await ref.read(authProvider.notifier).resetPassword(
        identifier: widget.identifier,
        otp: widget.otp,
        newPassword: _newPassCtrl.text,
      );
      widget.onReset();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (_, next) {
      if (next.error != null) AppSnackbar.error(context, next.error!);
    });
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

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
                    child: Icon(Icons.lock_open_rounded, size: 34, color: AppColors.teal),
                  ),
                ),
                const SizedBox(height: 20),
                AppText.h1(AppStrings.setNewPassword, fontWeight: FontWeight.w800),
                const SizedBox(height: 8),
                AppText.bodyMd(AppStrings.setNewPasswordSubtitle,
                    textAlign: TextAlign.center, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 32),

          AnimatedBuilder(
            animation: Listenable.merge([_newPassCtrl, _confirmPassCtrl]),
            builder: (_, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _newPassCtrl,
                  label: AppStrings.newPassword,
                  hint: AppStrings.newPasswordHint,
                  obscureText: true,
                  enabled: !isLoading,
                  errorText: isLoading ? null : _newPassError,
                  onChanged: (_) => setState(() { _newPassError = null; _matchError = null; }),
                ),

                if (_newPassCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  PasswordStrengthBar(password: _newPassCtrl.text),
                ],
                const SizedBox(height: 14),

                AppTextField(
                  controller: _confirmPassCtrl,
                  label: AppStrings.confirmPassword,
                  hint: AppStrings.confirmPasswordHint,
                  obscureText: true,
                  enabled: !isLoading,
                  errorText: isLoading ? null : _matchError,
                  onChanged: (_) => setState(() => _matchError = null),
                ),
                const SizedBox(height: 28),

                AuthButton(
                  label: AppStrings.resetPasswordBtn,
                  enabled: _canSubmit && !isLoading,
                  loading: isLoading,
                  onPressed: _reset,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
