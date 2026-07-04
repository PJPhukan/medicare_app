import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_shell.dart';
import '../../../../core/utils/validators.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.onSent,
    required this.onBack,
  });

  final ValueChanged<String> onSent;
  final VoidCallback onBack;

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _idCtrl = TextEditingController();
  String? _idError;

  @override
  void dispose() {
    _idCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => _idCtrl.text.trim().isNotEmpty;

  Future<void> _send() async {
    final err = Validators.email(_idCtrl.text);
    if (err != null) { setState(() => _idError = err); return; }
    final id = _idCtrl.text.trim();
    try {
      await ref.read(authProvider.notifier).forgotPassword(identifier: id);
      widget.onSent(id);
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
                    child: Icon(Icons.lock_reset_rounded, size: 34, color: AppColors.teal),
                  ),
                ),
                const SizedBox(height: 20),
                AppText.h1(AppStrings.forgotPasswordTitle, fontWeight: FontWeight.w800),
                const SizedBox(height: 8),
                AppText.bodyMd(AppStrings.forgotPasswordSubtitle,
                    textAlign: TextAlign.center, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 32),

          AnimatedBuilder(
            animation: _idCtrl,
            builder: (_, __) => AppTextField(
              controller: _idCtrl,
              label: AppStrings.email,
              hint: 'name@example.com',
              keyboardType: TextInputType.emailAddress,
              enabled: !isLoading,
              errorText: isLoading ? null : _idError,
              onChanged: (_) => setState(() => _idError = null),
              prefix: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 28),

          AnimatedBuilder(
            animation: _idCtrl,
            builder: (_, __) => AuthButton(
              label: AppStrings.sendResetCode,
              enabled: _canSubmit && !isLoading,
              loading: isLoading,
              onPressed: _send,
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText.bodyMd('Remember it? '),
              GestureDetector(
                onTap: widget.onBack,
                child: AppText.bodyMd(AppStrings.signIn,
                    fontWeight: FontWeight.w700, color: AppColors.teal),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
