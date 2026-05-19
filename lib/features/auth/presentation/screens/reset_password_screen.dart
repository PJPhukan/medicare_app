import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../widgets/auth_shell.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.onReset,
    required this.onBack,
  });

  final VoidCallback onReset;
  final VoidCallback onBack;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPassCtrl     = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _showNew     = false;
  bool _showConfirm = false;
  String? _newPassError;
  String? _matchError;

  @override
  void dispose() {
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  _Strength get _strength {
    final p = _newPassCtrl.text;
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
      _newPassCtrl.text.isNotEmpty && _confirmPassCtrl.text.isNotEmpty;

  void _reset() {
    final passErr = Validators.password(_newPassCtrl.text);
    if (passErr != null) { setState(() { _newPassError = passErr; }); return; }
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      setState(() => _matchError = AppStrings.passwordsDoNotMatch2);
      return;
    }
    widget.onReset();
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
                Text(AppStrings.setNewPassword,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26, fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1A202C),
                      letterSpacing: -0.3,
                    )),
                const SizedBox(height: 8),
                Text(AppStrings.setNewPasswordSubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 13, color: secondaryColor)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          AnimatedBuilder(
            animation: Listenable.merge([_newPassCtrl, _confirmPassCtrl]),
            builder: (_, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthField(
                  controller: _newPassCtrl,
                  label: AppStrings.newPassword,
                  hint: AppStrings.newPasswordHint,
                  obscureText: !_showNew,
                  error: _newPassError,
                  onChanged: (_) => setState(() { _newPassError = null; _matchError = null; }),
                  suffix: IconButton(
                    icon: Icon(
                      _showNew ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 18, color: hintColor,
                    ),
                    onPressed: () => setState(() => _showNew = !_showNew),
                  ),
                ),

                // Strength meter
                if (_newPassCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _strength.pct,
                            minHeight: 4,
                            backgroundColor: isDark ? AppColors.dark600 : const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation(_strength.color),
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
                const SizedBox(height: 14),

                AuthField(
                  controller: _confirmPassCtrl,
                  label: AppStrings.confirmPassword,
                  hint: AppStrings.confirmPasswordHint,
                  obscureText: !_showConfirm,
                  error: _matchError,
                  onChanged: (_) => setState(() => _matchError = null),
                  suffix: IconButton(
                    icon: Icon(
                      _showConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 18, color: hintColor,
                    ),
                    onPressed: () => setState(() => _showConfirm = !_showConfirm),
                  ),
                ),
                const SizedBox(height: 28),

                AuthButton(
                  label: AppStrings.resetPasswordBtn,
                  enabled: _canSubmit,
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

class _Strength {
  const _Strength(this.label, this.pct, this.color);
  final String label;
  final double pct;
  final Color color;
}
