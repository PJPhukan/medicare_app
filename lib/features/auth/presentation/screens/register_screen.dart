import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/country_codes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../core/utils/logger.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_shell.dart';
import '../widgets/auth_social_buttons.dart';
import '../widgets/password_strength_bar.dart';
import 'auth_flow.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({
    super.key,
    required this.draft,
    required this.onContinue,
    required this.onLogin,
    required this.onBack,
    required this.onDraftChanged,
  });

  final AuthDraft     draft;
  final VoidCallback  onContinue;
  final VoidCallback  onLogin;
  final VoidCallback  onBack;
  final void Function(AuthDraft) onDraftChanged;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  bool _submitted  = false;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _passCtrl;
  CountryCode _phoneCountry = kDefaultCountry;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.draft.name);
    _emailCtrl = TextEditingController(text: widget.draft.email);
    _phoneCtrl = TextEditingController(text: widget.draft.phone);
    _passCtrl  = TextEditingController(text: widget.draft.password);

    // listenManual so error snackbar fires once, not on every rebuild
    ref.listenManual(authProvider, (_, next) {
      if (next.error != null && mounted) {
        AppSnackbar.error(context, next.error!);
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _nameCtrl.text.trim().isNotEmpty &&
      _emailCtrl.text.trim().isNotEmpty &&
      _phoneCtrl.text.trim().isNotEmpty &&
      _passCtrl.text.isNotEmpty;

  String get _e164Phone {
    final raw = _phoneCtrl.text.trim();
    if (raw.isEmpty || raw.startsWith('+')) return raw;
    return '${_phoneCountry.code}$raw';
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    final name     = _nameCtrl.text.trim();
    final email    = _emailCtrl.text.trim().toLowerCase();
    final phone    = _e164Phone;
    final password = _passCtrl.text;

    try {
      await ref.read(authProvider.notifier).register(
        name: name, email: email, phone: phone, password: password,
      );
    } catch (e, s) {
      AppLogger.e('RegisterScreen._submit', error: e, stack: s);
      return;
    }

    if (!mounted) return;
    widget.onDraftChanged(widget.draft.copyWith(
      name: name, email: email, phone: phone, password: password,
    ));
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return AuthShell(
      leading: AppBarLeading.back,
      onBack:  widget.onBack,
      child: Form(
        key: _formKey,
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
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
                  AppText.bodyMd(AppStrings.registerSubtitle, color: context.secondaryText),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            AppTextField(
              controller: _nameCtrl,
              label:      AppStrings.fullName,
              hint:       AppStrings.fullNameHint,
              enabled:    !isLoading,
              validator:  Validators.name,
            ),
            
            const SizedBox(height: 14),

            AppTextField(
              controller:    _emailCtrl,
              label:         AppStrings.email,
              hint:          AppStrings.emailHint,
              keyboardType:  TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              enabled:       !isLoading,
              validator:     Validators.email,
            ),
            
            const SizedBox(height: 14),

            AppPhoneInput(
              controller: _phoneCtrl,
              enabled:    !isLoading,
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
              controller:    _passCtrl,
              label:         AppStrings.password,
              hint:          AppStrings.passwordCreateHint,
              obscureText:   true,
              autofillHints: const [AutofillHints.newPassword],
              enabled:       !isLoading,
              validator:     Validators.password,
            ),

            ValueListenableBuilder(
              valueListenable: _passCtrl,
              builder: (_, value, __) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: [
                    const SizedBox(height: 8),
                    PasswordStrengthBar(password: value.text),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 20),

            // Only rebuild the button when field content changes
            ListenableBuilder(
              listenable: Listenable.merge([
                _nameCtrl, _emailCtrl, _phoneCtrl, _passCtrl,
              ]),
              builder: (_, __) => AuthButton(
                label:     AppStrings.continueText,
                enabled:   _canSubmit && !isLoading,
                loading:   isLoading,
                onPressed: _submit,
              ),
            ),

            const SizedBox(height: 24),
            
            AuthDivider(label: AppStrings.orContinueWith),
           
            const SizedBox(height: 20),

            const AuthSocialButtons(),
            
            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText.bodyMd('${AppStrings.alreadyHaveAccount} '),
                InkWell(
                  onTap:        widget.onLogin,
                  borderRadius: BorderRadius.circular(4),
                  child:        AppText.bodyMd(
                    AppStrings.signIn,
                    fontWeight: FontWeight.w700,
                    color:      AppColors.teal,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
