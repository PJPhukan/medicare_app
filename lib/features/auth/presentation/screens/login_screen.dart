import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../widgets/auth_shell.dart';
import '../widgets/email_phone_input.dart';
import 'auth_flow.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.draft,
    required this.onSentOtp,
    required this.onRegister,
    this.onLoggedIn,
    this.onForgotPassword,
  });

  final AuthDraft draft;
  final VoidCallback onSentOtp;
  final VoidCallback onRegister;
  final VoidCallback? onLoggedIn;
  final VoidCallback? onForgotPassword;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _idCtrl;
  late final TextEditingController _passCtrl;
  bool _showPass = false;
  bool _useOtp = false;
  String? _idError;
  String? _passError;

  @override
  void initState() {
    super.initState();
    _idCtrl   = TextEditingController(text: widget.draft.identifier);
    _passCtrl = TextEditingController(text: widget.draft.password);
    _useOtp   = widget.draft.useOtp;
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => _idCtrl.text.trim().isNotEmpty &&
      (_useOtp || _passCtrl.text.isNotEmpty);

  bool _validate() {
    final idErr   = Validators.emailOrPhone(_idCtrl.text);
    final passErr = _useOtp ? null : Validators.password(_passCtrl.text);
    setState(() { _idError = idErr; _passError = passErr; });
    return idErr == null && passErr == null;
  }

  void _submit() {
    if (!_validate()) return;
    widget.draft.identifier = _idCtrl.text.trim();
    widget.draft.password   = _passCtrl.text;
    widget.draft.useOtp     = _useOtp;
    if (_useOtp) {
      widget.onSentOtp();
    } else {
      widget.onLoggedIn?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textSecondary : const Color(0xFF64748B);
    final hintColor = isDark ? AppColors.textHint : const Color(0xFF94A3B8);

    return AuthShell(
      showBack: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Center(child: AuthBrand()),
          const SizedBox(height: 28),

          Center(
            child: Column(
              children: [
                Text(AppStrings.welcomeBack,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28, fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1A202C),
                      letterSpacing: -0.5,
                    )),
                const SizedBox(height: 6),
                Text(AppStrings.loginSubtitle,
                    style: GoogleFonts.inter(fontSize: 14, color: secondaryColor)),
              ],
            ),
          ),
          const SizedBox(height: 28),

          AppEmailPhoneInput(
            controller: _idCtrl,
            label: AppStrings.emailOrMobile,
            hint: AppStrings.emailOrMobileHint,
            error: _idError,
            onChanged: (_) => setState(() => _idError = null),
          ),

          const SizedBox(height: 14),

          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: _useOtp
                ? const SizedBox.shrink()
                : AnimatedBuilder(
                    animation: _passCtrl,
                    builder: (_, __) => AuthField(
                      controller: _passCtrl,
                      label: AppStrings.password,
                      hint: AppStrings.passwordHint,
                      obscureText: !_showPass,
                      error: _passError,
                      onChanged: (_) => setState(() => _passError = null),
                      suffix: IconButton(
                        icon: Icon(
                          _showPass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          size: 18, color: hintColor,
                        ),
                        onPressed: () => setState(() => _showPass = !_showPass),
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() { _useOtp = !_useOtp; _passError = null; }),
                child: Text(
                  _useOtp ? AppStrings.usePasswordInstead : AppStrings.useOtpInstead,
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: AppColors.teal,
                  ),
                ),
              ),
              if (!_useOtp)
                GestureDetector(
                  onTap: widget.onForgotPassword,
                  child: Text(AppStrings.forgotPassword,
                      style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: secondaryColor,
                      )),
                ),
            ],
          ),

          const SizedBox(height: 24),

          AnimatedBuilder(
            animation: Listenable.merge([_idCtrl, _passCtrl]),
            builder: (_, __) => AuthButton(
              label: _useOtp ? AppStrings.sendOtp : AppStrings.signIn,
              enabled: _canSubmit,
              onPressed: _submit,
            ),
          ),

          const SizedBox(height: 28),
          AuthDivider(label: AppStrings.orContinueWith),
          const SizedBox(height: 20),

          SocialButtons(onGoogle: () {}, onApple: () {}),
          const SizedBox(height: 32),

          Center(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: 14, color: secondaryColor),
                children: [
                  TextSpan(text: '${AppStrings.dontHaveAccount} '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: widget.onRegister,
                      child: Text(AppStrings.signUp,
                          style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: AppColors.teal,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
