import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/patients_provider.dart';

/// Lets a caretaker add a new dependent patient profile — a name is enough;
/// phone/email are optional and only matter if this person will later join
/// with their own account.
Future<bool?> showAddPatientSheet(BuildContext context) {
  return AppBottomSheet.show<bool>(
    context,
    title: AppStrings.addPatient,
    subtitle: 'Someone you manage medicines and care for',
    child: const _AddPatientBody(),
  );
}

const _kRelations = ['Mother', 'Father', 'Spouse', 'Child', 'Other'];

class _AddPatientBody extends ConsumerStatefulWidget {
  const _AddPatientBody();

  @override
  ConsumerState<_AddPatientBody> createState() => _AddPatientBodyState();
}

class _AddPatientBodyState extends ConsumerState<_AddPatientBody> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String? _relation;
  bool _saving = false;
  String? _nameError;
  String? _phoneError;
  String? _emailError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    final nameErr = name.length < 2 ? AppStrings.nameTooShort : null;
    final phoneErr = phone.isEmpty ? null : Validators.phone(phone);
    final emailErr = email.isEmpty ? null : Validators.email(email);
    if (nameErr != null || phoneErr != null || emailErr != null) {
      setState(() {
        _nameError = nameErr;
        _phoneError = phoneErr;
        _emailError = emailErr;
      });
      return;
    }

    setState(() => _saving = true);
    final ok = await ref.read(patientsProvider.notifier).addPatient(
          name: name,
          phone: phone.isEmpty ? null : phone,
          email: email.isEmpty ? null : email,
          relation: _relation,
        );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
      AppSnackbar.success(context, 'Patient added');
    } else {
      setState(() => _saving = false);
      AppSnackbar.error(context,
          ref.read(patientsProvider).error ?? AppStrings.somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.labelXs('FULL NAME', color: AppColors.textHint, fontWeight: FontWeight.w600),
        const SizedBox(height: 10),
        AppTextField(
          controller: _nameCtrl,
          hint: 'e.g. Sunita Kumar',
          errorText: _nameError,
          onChanged: (_) => setState(() => _nameError = null),
        ),
        const SizedBox(height: 20),

        AppText.labelXs('RELATION', color: AppColors.textHint, fontWeight: FontWeight.w600),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _kRelations
              .map((r) => AppFilterChip(
                    label: r,
                    selected: _relation == r,
                    color: AppColors.teal,
                    onTap: () => setState(() => _relation = _relation == r ? null : r),
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),

        AppText.labelXs('PHONE (OPTIONAL)', color: AppColors.textHint, fontWeight: FontWeight.w600),
        const SizedBox(height: 10),
        AppTextField(
          controller: _phoneCtrl,
          hint: 'Lets them join with their own account later',
          keyboardType: TextInputType.phone,
          errorText: _phoneError,
          onChanged: (_) => setState(() => _phoneError = null),
        ),
        const SizedBox(height: 20),

        AppText.labelXs('EMAIL (OPTIONAL)', color: AppColors.textHint, fontWeight: FontWeight.w600),
        const SizedBox(height: 10),
        AppTextField(
          controller: _emailCtrl,
          hint: 'name@example.com',
          keyboardType: TextInputType.emailAddress,
          errorText: _emailError,
          onChanged: (_) => setState(() => _emailError = null),
        ),
        const SizedBox(height: 28),

        AppButton(
          label: AppStrings.addPatient,
          isFullWidth: true,
          isLoading: _saving,
          variant: AppButtonVariant.primary,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }
}
