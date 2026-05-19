import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../widgets/auth_shell.dart';
import 'auth_flow.dart';

const _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.draft,
    required this.onContinue,
    required this.onBack,
  });

  final AuthDraft draft;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final TextEditingController _ageCtrl;
  String _bloodGroup = '';
  String? _ageError;

  @override
  void initState() {
    super.initState();
    _ageCtrl    = TextEditingController(text: widget.draft.age);
    _bloodGroup = widget.draft.bloodGroup;
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    final err = Validators.age(_ageCtrl.text);
    if (err != null) { setState(() => _ageError = err); return; }
    widget.draft.age        = _ageCtrl.text.trim();
    widget.draft.bloodGroup = _bloodGroup;
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textSecondary : const Color(0xFF64748B);
    final borderColor = isDark ? AppColors.dark600 : const Color(0xFFE2E8F0);
    final bgInput = isDark ? AppColors.dark700 : Colors.white;

    return AuthShell(
      showBack: true,
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Center(child: AuthBrand()),
          const SizedBox(height: 16),

          AuthStepper(steps: const ['Account', 'Health', 'Emergency', 'Plan'], current: 1),

          Center(
            child: Column(
              children: [
                Text(AppStrings.quizTitle,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26, fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1A202C),
                      letterSpacing: -0.3,
                    )),
                const SizedBox(height: 6),
                Text(AppStrings.quizSubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 13, color: secondaryColor)),
              ],
            ),
          ),
          const SizedBox(height: 28),

          Text(AppStrings.yourAge,
              style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: secondaryColor, letterSpacing: 0.3,
              )),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _ageCtrl,
            builder: (_, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 3,
                  onChanged: (_) => setState(() => _ageError = null),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28, fontWeight: FontWeight.w800,
                    color: AppColors.teal,
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.ageHint,
                    hintStyle: GoogleFonts.spaceGrotesk(
                      fontSize: 28, fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.dark600 : const Color(0xFFCBD5E1),
                    ),
                    filled: true,
                    fillColor: bgInput,
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: _ageError != null ? AppColors.error : borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: _ageError != null ? AppColors.error : AppColors.teal,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                if (_ageError != null) ...[
                  const SizedBox(height: 4),
                  Text(_ageError!,
                      style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      )),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Text(AppStrings.bloodGroup,
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: secondaryColor, letterSpacing: 0.3,
                  )),
              const SizedBox(width: 8),
              Text('(${AppStrings.optional})',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? AppColors.dark500 : const Color(0xFFCBD5E1),
                  )),
            ],
          ),
          const SizedBox(height: 10),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2,
            ),
            itemCount: _bloodGroups.length,
            itemBuilder: (_, i) {
              final bg = _bloodGroups[i];
              final active = _bloodGroup == bg;
              return GestureDetector(
                onTap: () => setState(() => _bloodGroup = active ? '' : bg),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: active ? AppColors.teal.withValues(alpha: 0.12) : bgInput,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: active ? AppColors.teal.withValues(alpha: 0.5) : borderColor,
                    ),
                  ),
                  child: Center(
                    child: Text(bg,
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: active ? AppColors.teal : secondaryColor,
                        )),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          AnimatedBuilder(
            animation: _ageCtrl,
            builder: (_, __) => AuthButton(
              label: AppStrings.continueText,
              enabled: _ageCtrl.text.trim().isNotEmpty,
              onPressed: _continue,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
