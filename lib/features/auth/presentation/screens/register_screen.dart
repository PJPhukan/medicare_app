import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/country_codes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/inputs/phone_input.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_shell.dart';
import '../widgets/password_strength_bar.dart';
import 'auth_flow.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({
    super.key,
    required this.draft,
    required this.onContinue,
    required this.onLogin,
    required this.onBack,
  });

  final AuthDraft draft;
  final VoidCallback onContinue;
  final VoidCallback onLogin;
  final VoidCallback onBack;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _passCtrl;
  final Map<String, String?> _errors = {};
  CountryCode _phoneCountry = kDefaultCountry;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.draft.name);
    _emailCtrl = TextEditingController(text: widget.draft.email);
    _phoneCtrl = TextEditingController(text: widget.draft.phone);
    _passCtrl  = TextEditingController(text: widget.draft.password);
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _nameCtrl.text.trim().isNotEmpty &&
      _emailCtrl.text.trim().isNotEmpty &&
      _phoneCtrl.text.trim().isNotEmpty &&
      _passCtrl.text.isNotEmpty;

  bool _validate() {
    final errs = {
      'name':     Validators.name(_nameCtrl.text),
      'email':    Validators.email(_emailCtrl.text),
      'phone':    Validators.phone(_phoneCtrl.text),
      'password': Validators.password(_passCtrl.text),
    };
    setState(() { _errors..clear()..addAll(errs); });
    return errs.values.every((e) => e == null);
  }

  String get _e164Phone {
    final raw = _phoneCtrl.text.trim();
    if (raw.isEmpty || raw.startsWith('+')) return raw;
    return '${_phoneCountry.code}$raw';
  }

  Future<void> _continue() async {
    if (!_validate()) return;
    widget.draft.name     = _nameCtrl.text.trim();
    widget.draft.email    = _emailCtrl.text.trim();
    widget.draft.phone    = _e164Phone;
    widget.draft.password = _passCtrl.text;
    try {
      await ref.read(authProvider.notifier).register(
        name: widget.draft.name,
        email: widget.draft.email,
        phone: widget.draft.phone,
        password: widget.draft.password,
      );
      widget.onContinue();
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
      showBack: true,
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Center(child: AppBrand()),
          const SizedBox(height: 24),

          Center(
            child: Column(
              children: [
                AppText.h1(AppStrings.createAccount, fontWeight: FontWeight.w800),
                const SizedBox(height: 6),
                AppText.bodyMd(AppStrings.registerSubtitle, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 24),

          AnimatedBuilder(
            animation: Listenable.merge([_nameCtrl, _emailCtrl, _phoneCtrl, _passCtrl]),
            builder: (_, __) => Column(
              children: [
                AppTextField(
                  controller: _nameCtrl,
                  label: AppStrings.fullName,
                  hint: AppStrings.fullNameHint,
                  enabled: !isLoading,
                  errorText: isLoading ? null : _errors['name'],
                  onChanged: (_) => setState(() => _errors.remove('name')),
                ),
                const SizedBox(height: 14),

                AppTextField(
                  controller: _emailCtrl,
                  label: AppStrings.email,
                  hint: AppStrings.emailHint,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                  errorText: isLoading ? null : _errors['email'],
                  onChanged: (_) => setState(() => _errors.remove('email')),
                ),
                const SizedBox(height: 14),

                AppPhoneInput(
                  controller: _phoneCtrl,
                  label: AppStrings.mobileNumber,
                  hint: AppStrings.mobileHint,
                  enabled: !isLoading,
                  error: isLoading ? null : _errors['phone'],
                  onChanged: (_) => setState(() => _errors.remove('phone')),
                  onCountryChanged: (region) {
                    final country = kCountryCodes.firstWhere(
                      (c) => c.region == region,
                      orElse: () => kDefaultCountry,
                    );
                    setState(() => _phoneCountry = country);
                  },
                ),
                const SizedBox(height: 14),

                AppTextField(
                  controller: _passCtrl,
                  label: AppStrings.password,
                  hint: AppStrings.passwordCreateHint,
                  obscureText: true,
                  enabled: !isLoading,
                  errorText: isLoading ? null : _errors['password'],
                  onChanged: (_) => setState(() => _errors.remove('password')),
                ),

                if (_passCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  PasswordStrengthBar(password: _passCtrl.text),
                ],
                const SizedBox(height: 20),

                AuthButton(
                  label: AppStrings.continueText,
                  enabled: _canSubmit && !isLoading,
                  loading: isLoading,
                  onPressed: _continue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

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
          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText.bodyMd('${AppStrings.alreadyHaveAccount} '),
              GestureDetector(
                onTap: widget.onLogin,
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
