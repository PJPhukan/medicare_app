import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/country_codes.dart';
import '../widgets/auth_shell.dart';
import '../../../../core/utils/validators.dart';
import '../widgets/phone_input_widget.dart';

enum _InputType { unknown, email, phone }

_InputType _detectType(String value) {
  if (value.isEmpty) return _InputType.unknown;
  if (RegExp(r'[A-Za-z]').hasMatch(value)) return _InputType.email;
  if (RegExp(r'^[+\d\s()\-]+$').hasMatch(value)) return _InputType.phone;
  return _InputType.unknown;
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.onSent,
    required this.onBack,
  });

  // onSent receives the identifier so OTP screen can display it
  final ValueChanged<String> onSent;
  final VoidCallback onBack;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _idCtrl = TextEditingController();
  _InputType _inputType = _InputType.unknown;
  CountryCode _country = kDefaultCountry;
  String? _idError;

  @override
  void dispose() {
    _idCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => _idCtrl.text.trim().isNotEmpty;

  void _send() {
    final err = Validators.emailOrPhone(_idCtrl.text);
    if (err != null) { setState(() => _idError = err); return; }
    final id = _inputType == _InputType.phone
        ? '${_country.code}${_idCtrl.text.trim()}'
        : _idCtrl.text.trim();
    widget.onSent(id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textSecondary : const Color(0xFF64748B);
    final hintColor = isDark ? AppColors.textHint : const Color(0xFF94A3B8);
    final borderColor = _idError != null
        ? AppColors.error
        : isDark ? AppColors.dark600 : const Color(0xFFE2E8F0);
    final bgInput = isDark ? AppColors.dark700 : Colors.white;
    final textColor = isDark ? AppColors.textPrimary : const Color(0xFF1A202C);
    final isPhone = _inputType == _InputType.phone;

    return AuthShell(
      showBack: true,
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Center(child: AuthBrand()),
          const SizedBox(height: 32),

          Center(
            child: Column(
              children: [
                // Lock icon
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
                Text(AppStrings.forgotPasswordTitle,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26, fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1A202C),
                      letterSpacing: -0.3,
                    )),
                const SizedBox(height: 8),
                Text(AppStrings.forgotPasswordSubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 13, color: secondaryColor)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Text(AppStrings.emailOrMobile,
              style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: secondaryColor, letterSpacing: 0.3,
              )),
          const SizedBox(height: 6),

          // Smart identifier: country picker slides in for phone
          AnimatedBuilder(
            animation: _idCtrl,
            builder: (_, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      child: isPhone
                          ? Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: CountryCodePicker(
                                selected: _country,
                                onSelected: (c) => setState(() => _country = c),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: TextField(
                          controller: _idCtrl,
                          keyboardType: TextInputType.text,
                          onChanged: (v) => setState(() {
                            _inputType = _detectType(v);
                            _idError = null;
                          }),
                          style: GoogleFonts.inter(fontSize: 15, color: textColor),
                          decoration: InputDecoration(
                            hintText: AppStrings.emailOrMobileHint,
                            hintStyle: GoogleFonts.inter(fontSize: 15, color: hintColor),
                            filled: true,
                            fillColor: bgInput,
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: _idError != null ? AppColors.error : AppColors.teal,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_idError != null) ...[
                  const SizedBox(height: 4),
                  Text(_idError!,
                      style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      )),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),

          AnimatedBuilder(
            animation: _idCtrl,
            builder: (_, __) => AuthButton(
              label: AppStrings.sendResetCode,
              enabled: _canSubmit,
              onPressed: _send,
            ),
          ),
          const SizedBox(height: 20),

          Center(
            child: GestureDetector(
              onTap: widget.onBack,
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(fontSize: 14, color: secondaryColor),
                  children: [
                    const TextSpan(text: 'Remember it? '),
                    TextSpan(
                      text: AppStrings.signIn,
                      style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppColors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
