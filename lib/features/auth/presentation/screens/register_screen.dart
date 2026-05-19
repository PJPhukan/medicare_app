import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../widgets/auth_shell.dart';
import '../widgets/phone_input_widget.dart';
import 'auth_flow.dart';

class RegisterScreen extends StatefulWidget {
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
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _passCtrl;
  bool _showPass = false;
  final Map<String, String?> _errors = {};

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

  _Strength get _strength {
    final p = _passCtrl.text;
    int score = 0;
    if (p.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(p)) score++;
    if (RegExp(r'[0-9]').hasMatch(p)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) score++;
    final levels = [
      _Strength(AppStrings.strengthVeryWeak, 0.08, const Color(0xFFf87171)),
      _Strength(AppStrings.strengthWeak,     0.25, const Color(0xFFfb7185)),
      _Strength(AppStrings.strengthFair,     0.50, const Color(0xFFF59E0B)),
      _Strength(AppStrings.strengthGood,     0.75, const Color(0xFF60a5fa)),
      _Strength(AppStrings.strengthStrong,   1.00, AppColors.teal),
    ];
    return levels[score];
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
    setState(() { _errors
      ..clear()
      ..addAll(errs); });
    return errs.values.every((e) => e == null);
  }

  void _continue() {
    if (!_validate()) return;
    widget.draft.name     = _nameCtrl.text.trim();
    widget.draft.email    = _emailCtrl.text.trim();
    widget.draft.phone    = _phoneCtrl.text.trim();
    widget.draft.password = _passCtrl.text;
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textSecondary : const Color(0xFF64748B);
    final hintColor = isDark ? AppColors.textHint : const Color(0xFF94A3B8);

    return AuthShell(
      showBack: true,
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Center(child: AuthBrand()),
          const SizedBox(height: 24),

          Center(
            child: Column(
              children: [
                Text(AppStrings.createAccount,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26, fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1A202C),
                      letterSpacing: -0.3,
                    )),
                const SizedBox(height: 6),
                Text(AppStrings.registerSubtitle,
                    style: GoogleFonts.inter(fontSize: 14, color: secondaryColor)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          AnimatedBuilder(
            animation: Listenable.merge([_nameCtrl, _emailCtrl, _phoneCtrl, _passCtrl]),
            builder: (_, __) => Column(
              children: [
                AuthField(
                  controller: _nameCtrl,
                  label: AppStrings.fullName,
                  hint: AppStrings.fullNameHint,
                  error: _errors['name'],
                  onChanged: (_) => setState(() => _errors.remove('name')),
                ),
                const SizedBox(height: 14),

                AuthField(
                  controller: _emailCtrl,
                  label: AppStrings.email,
                  hint: AppStrings.emailHint,
                  keyboardType: TextInputType.emailAddress,
                  error: _errors['email'],
                  onChanged: (_) => setState(() => _errors.remove('email')),
                ),
                const SizedBox(height: 14),

                PhoneField(
                  controller: _phoneCtrl,
                  label: AppStrings.mobileNumber,
                  hint: AppStrings.mobileHint,
                  error: _errors['phone'],
                  onChanged: (_) => setState(() => _errors.remove('phone')),
                ),
                const SizedBox(height: 14),

                AuthField(
                  controller: _passCtrl,
                  label: AppStrings.password,
                  hint: AppStrings.passwordCreateHint,
                  obscureText: !_showPass,
                  error: _errors['password'],
                  onChanged: (_) => setState(() => _errors.remove('password')),
                  suffix: IconButton(
                    icon: Icon(
                      _showPass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 18, color: hintColor,
                    ),
                    onPressed: () => setState(() => _showPass = !_showPass),
                  ),
                ),

                if (_passCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 4,
                            child: LinearProgressIndicator(
                              value: _strength.pct,
                              backgroundColor: isDark ? AppColors.dark600 : const Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation(_strength.color),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(_strength.label,
                          style: GoogleFonts.inter(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: _strength.color,
                          )),
                    ],
                  ),
                ],
                const SizedBox(height: 20),

                AuthButton(
                  label: AppStrings.continueText,
                  enabled: _canSubmit,
                  onPressed: _continue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          AuthDivider(label: AppStrings.orContinueWith),
          const SizedBox(height: 20),

          SocialButtons(onGoogle: () {}, onApple: () {}),
          const SizedBox(height: 28),

          Center(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: 14, color: secondaryColor),
                children: [
                  TextSpan(text: '${AppStrings.alreadyHaveAccount} '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: widget.onLogin,
                      child: Text(AppStrings.signIn,
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

class _Strength {
  const _Strength(this.label, this.pct, this.color);
  final String label;
  final double pct;
  final Color color;
}
