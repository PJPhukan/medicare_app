import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/constants/app_strings.dart';
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
    required this.onDraftChanged,
  });

  final AuthDraft draft;
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final void Function(AuthDraft) onDraftChanged;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final TextEditingController _ageCtrl;
  String _bloodGroup = '';

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
    final age = _ageCtrl.text.trim();
    if (Validators.age(age) != null) return;
    widget.onDraftChanged(widget.draft.copyWith(
      age: age,
      bloodGroup: _bloodGroup,
    ));
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      leading: AppBarLeading.back,
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Center(child: AppBrand()),
          const SizedBox(height: 16),

          Center(
            child: Column(
              children: [
                AppText.h1(AppStrings.quizTitle, fontWeight: FontWeight.w800),
                const SizedBox(height: 6),
                AppText.bodyMd(AppStrings.quizSubtitle,
                    color: context.secondaryText, textAlign: TextAlign.center),
              ],
            ),
          ),

          const SizedBox(height: 28),

          ValueListenableBuilder(
            valueListenable: _ageCtrl,
            builder: (_, __, ___) {
              final age   = _ageCtrl.text.trim();
              final error = Validators.age(age);
              return AppTextField(
                controller:      _ageCtrl,
                label:           AppStrings.yourAge,
                hint:            AppStrings.ageHint,
                keyboardType:    TextInputType.number,
                maxLength:       3,
                errorText:       age.isNotEmpty ? error : null,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              );
            },
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              AppText.labelSm(AppStrings.bloodGroup, color: context.secondaryText),
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

          ValueListenableBuilder(
            valueListenable: _ageCtrl,
            builder: (_, __, ___) => AuthButton(
              label:     AppStrings.continueText,
              enabled:   Validators.age(_ageCtrl.text.trim()) == null,
              onPressed: _continue,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
