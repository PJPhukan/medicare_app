import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/country_codes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/inputs/email_phone_input.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_shell.dart';
import 'auth_flow.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final AuthDraft draft;
  final VoidCallback onSentOtp;
  final VoidCallback onRegister;
  final VoidCallback? onLoggedIn;
  final VoidCallback? onForgotPassword;

 const LoginScreen({
    super.key,
    required this.draft,
    required this.onSentOtp,
    required this.onRegister,
    this.onLoggedIn,
    this.onForgotPassword,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _idCtrl;
  late final TextEditingController _passCtrl;
  bool _useOtp = false;
  String? _idError;
  String? _passError;
  CountryCode _country = kDefaultCountry;

  @override
  void initState() {
    super.initState();
    _idCtrl  = TextEditingController(text: widget.draft.identifier);
    _passCtrl = TextEditingController(text: widget.draft.password);
    _useOtp  = widget.draft.useOtp;
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => _idCtrl.text.trim().isNotEmpty &&
      (_useOtp || _passCtrl.text.isNotEmpty);

  /// Returns the identifier with country code prepended for phone numbers.
  String get _identifier {
    final raw = _idCtrl.text.trim();
    // If it has no '@' and no leading '+', it's a bare phone number — prepend country code.
    if (!raw.contains('@') && !raw.startsWith('+')) return '${_country.code}$raw';
    return raw;
  }

  bool _validate() {
    final idErr   = Validators.emailOrPhone(_idCtrl.text);
    final passErr = _useOtp ? null : Validators.password(_passCtrl.text);
    setState(() { _idError = idErr; _passError = passErr; });
    return idErr == null && passErr == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    final id   = _identifier;
    final pass = _passCtrl.text;
    widget.draft.identifier = id;
    widget.draft.password   = pass;
    widget.draft.useOtp     = _useOtp;
    try {
      if (_useOtp) {
        await ref.read(authProvider.notifier).sendOtp(identifier: id, purpose: 'LOGIN');
        widget.onSentOtp();
      } else {
        await ref.read(authProvider.notifier).loginWithPassword(identifier: id, password: pass);
        widget.onLoggedIn?.call();
      }
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
      showBack: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Center(child: AppBrand()),
          const SizedBox(height: 28),

          Center(
            child: Column(
              children: [
                AppText.h1(AppStrings.welcomeBack, fontWeight: FontWeight.w800),
                const SizedBox(height: 6),
                AppText.bodyMd(AppStrings.loginSubtitle, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 28),

          AppEmailPhoneInput(
            controller: _idCtrl,
            label: AppStrings.emailOrMobile,
            hint: AppStrings.emailOrMobileHint,
            error: isLoading ? null : _idError,
            enabled: !isLoading,
            onChanged: (_) => setState(() => _idError = null),
            onCountryChanged: (c) => setState(() => _country = c),
          ),
          const SizedBox(height: 14),

          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: _useOtp
                ? const SizedBox.shrink()
                : AppTextField(
                    controller: _passCtrl,
                    label: AppStrings.password,
                    hint: AppStrings.passwordHint,
                    obscureText: true,
                    enabled: !isLoading,
                    errorText: isLoading ? null : _passError,
                    onChanged: (_) => setState(() => _passError = null),
                  ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppButton.ghost(
                label: _useOtp ? AppStrings.usePasswordInstead : AppStrings.useOtpInstead,
                size: AppButtonSize.sm,
                color: AppColors.teal,
                onPressed: () => setState(() { _useOtp = !_useOtp; _passError = null; }),
              ),
              if (!_useOtp)
                AppButton.ghost(
                  label: AppStrings.forgotPassword,
                  size: AppButtonSize.sm,
                  color: AppColors.textSecondary,
                  onPressed: widget.onForgotPassword,
                ),
            ],
          ),
          const SizedBox(height: 24),

          AnimatedBuilder(
            animation: Listenable.merge([_idCtrl, _passCtrl]),
            builder: (_, __) => AuthButton(
              label: _useOtp ? AppStrings.sendOtp : AppStrings.signIn,
              enabled: _canSubmit && !isLoading,
              loading: isLoading,
              onPressed: _submit,
            ),
          ),

          const SizedBox(height: 28),
          AuthDivider(label: AppStrings.orContinueWith),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: AppButton.social(
                  label: 'Google',
                  logo: const AuthGoogleIcon(),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton.social(
                  label: 'Apple',
                  logo: const AuthAppleIcon(),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText.bodyMd('${AppStrings.dontHaveAccount} '),
              GestureDetector(
                onTap: widget.onRegister,
                child: AppText.bodyMd(AppStrings.signUp,
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
