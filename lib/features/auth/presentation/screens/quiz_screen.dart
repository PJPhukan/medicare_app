import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/auth_shell.dart';
import '../widgets/blood_group_grid.dart';
import 'auth_flow.dart';

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
    return AuthShell(
      showBack: true,
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Center(child: AppBrand()),
          const SizedBox(height: 16),

          AuthStepper(
              steps: const ['Account', 'Health', 'Emergency', 'Plan'], current: 1),

          Center(
            child: Column(
              children: [
                AppText.h1(AppStrings.quizTitle, fontWeight: FontWeight.w800),
                const SizedBox(height: 6),
                AppText.bodyMd(AppStrings.quizSubtitle, color: AppColors.textSecondary, textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 28),

          AppText.labelSm(AppStrings.yourAge, color: AppColors.textSecondary),
          const SizedBox(height: 8),

          AnimatedBuilder(
            animation: _ageCtrl,
            builder: (_, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Intentionally large custom age input — no generic equivalent
                TextField(
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 3,
                  onChanged: (_) => setState(() => _ageError = null),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: AppStrings.ageHint,
                    hintStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: context.borderCol),
                    filled: true,
                    fillColor: context.inputBg,
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: _ageError != null
                            ? AppColors.error
                            : context.borderCol,
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
                  AppText.labelSm(_ageError!, color: AppColors.error),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              AppText.labelSm(AppStrings.bloodGroup, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              AppText.bodyXs('(${AppStrings.optional})'),
            ],
          ),
          const SizedBox(height: 10),

          BloodGroupGrid(
            selected: _bloodGroup,
            onChanged: (v) => setState(() => _bloodGroup = v),
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
