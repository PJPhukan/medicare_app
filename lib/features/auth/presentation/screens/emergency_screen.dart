import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/auth_shell.dart';
import '../widgets/blood_group_grid.dart';
import 'auth_flow.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({
    super.key,
    required this.draft,
    required this.onContinue,
    required this.onSkip,
    required this.onBack,
  });

  final AuthDraft draft;
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  late final TextEditingController _allergiesCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  String _bloodGroup = '';
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _allergiesCtrl = TextEditingController(text: widget.draft.allergies);
    _nameCtrl      = TextEditingController(text: widget.draft.emergencyName);
    _phoneCtrl     = TextEditingController(text: widget.draft.emergencyPhone);
    _bloodGroup    = widget.draft.bloodGroup;
  }

  @override
  void dispose() {
    _allergiesCtrl.dispose(); _nameCtrl.dispose(); _phoneCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_phoneCtrl.text.trim().isNotEmpty) {
      final err = Validators.phone(_phoneCtrl.text);
      if (err != null) { setState(() => _phoneError = err); return; }
    }
    widget.draft.allergies      = _allergiesCtrl.text.trim();
    widget.draft.emergencyName  = _nameCtrl.text.trim();
    widget.draft.emergencyPhone = _phoneCtrl.text.trim();
    widget.draft.bloodGroup     = _bloodGroup;
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
              steps: const ['Account', 'Health', 'Emergency', 'Plan'], current: 2),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBadge(
                      label: AppStrings.emergencyBadge,
                      variant: AppBadgeVariant.red,
                    ),
                    const SizedBox(height: 10),
                    AppText.h1(AppStrings.emergencyTitle, fontWeight: FontWeight.w800),
                    const SizedBox(height: 4),
                    AppText.bodyMd(AppStrings.emergencySubtitle, color: AppColors.textSecondary),
                  ],
                ),
              ),
              AppButton.outline(
                label: AppStrings.skip,
                size: AppButtonSize.sm,
                color: AppColors.textSecondary,
                onPressed: widget.onSkip,
              ),
            ],
          ),
          const SizedBox(height: 20),

          AppText.labelSm(AppStrings.bloodGroup, color: AppColors.textSecondary),
          const SizedBox(height: 10),

          BloodGroupGrid(
            selected: _bloodGroup,
            onChanged: (v) => setState(() => _bloodGroup = v),
          ),
          const SizedBox(height: 18),

          AppTextField(
            controller: _allergiesCtrl,
            label: AppStrings.knownAllergies,
            hint: AppStrings.allergiesHint,
          ),
          const SizedBox(height: 14),

          AppText.labelSm(AppStrings.emergencyContact, color: AppColors.textSecondary),
          const SizedBox(height: 8),

          AppTextField(controller: _nameCtrl, hint: AppStrings.contactName),
          const SizedBox(height: 10),

          AppTextField(
            controller: _phoneCtrl,
            hint: AppStrings.phoneNumber,
            keyboardType: TextInputType.phone,
            errorText: _phoneError,
            onChanged: (_) => setState(() => _phoneError = null),
          ),
          const SizedBox(height: 24),

          AuthButton(label: AppStrings.saveAndContinue, onPressed: _save),
          const SizedBox(height: 12),

          Center(
            child: AppText.bodyXs(AppStrings.emergencyDataNote, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
