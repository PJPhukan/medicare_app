import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/country_codes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../emergency/data/datasources/emergency_remote_datasource.dart';
import '../widgets/auth_shell.dart';
import 'auth_flow.dart';

const _kConditionsPresets = [
  'Diabetes',
  'Hypertension',
  'Asthma',
  'Heart Disease',
  'Thyroid Disorder',
  'Arthritis',
  'COPD',
  'Kidney Disease',
  'Epilepsy',
];

const _kAllergiesPresets = [
  'Penicillin',
  'Aspirin',
  'Ibuprofen',
  'Peanuts',
  'Tree Nuts',
  'Milk',
  'Eggs',
  'Wheat',
  'Shellfish',
  'Latex',
];

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({
    super.key,
    required this.draft,
    required this.onContinue,
    required this.onSkip,
    required this.onBack,
    required this.onDraftChanged,
  });

  final AuthDraft draft;
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final VoidCallback onBack;
  final void Function(AuthDraft) onDraftChanged;

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _contactPhoneCtrl;

  DateTime? _dob;
  List<String> _conditions = [];
  List<String> _allergies = [];
  CountryCode _contactCountry = kDefaultCountry;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl          = TextEditingController(text: widget.draft.emergencyName);
    _contactPhoneCtrl  = TextEditingController(text: widget.draft.emergencyPhone);
    _conditions        = List<String>.from(widget.draft.conditions);
    _allergies         = List<String>.from(widget.draft.allergies);

    final dob = widget.draft.dob;
    if (dob.isNotEmpty) {
      _dob = DateTime.tryParse(dob);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactPhoneCtrl.dispose();
    super.dispose();
  }

  String get _e164ContactPhone {
    final raw = _contactPhoneCtrl.text.trim();
    if (raw.isEmpty || raw.startsWith('+')) return raw;
    return '${_contactCountry.code}$raw';
  }

  Future<void> _save() async {
    final contactName  = _nameCtrl.text.trim();
    final contactPhone = _e164ContactPhone;

    if (contactPhone.isNotEmpty) {
      final err = Validators.phone(contactPhone);
      if (err != null) {
        setState(() => _error = err);
        return;
      }
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      final ds = EmergencyRemoteDataSource(ref.read(dioProvider));

      await ds.updateProfile(
        allergies: _allergies,
        conditions: _conditions,
      );

      if (contactName.isNotEmpty && contactPhone.isNotEmpty) {
        await ds.addContact(name: contactName, phone: contactPhone);
      }

      if (_dob != null) {
        await ref.read(dioProvider).patch<void>(
          ApiConstants.myMedicalProfile,
          data: {'dateOfBirth': _dob!.toIso8601String().split('T').first},
        );
      }

      widget.onDraftChanged(widget.draft.copyWith(
        dob:            _dob?.toIso8601String().split('T').first ?? '',
        conditions:     _conditions,
        allergies:      _allergies,
        emergencyName:  contactName,
        emergencyPhone: contactPhone,
      ));
      widget.onContinue();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
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

          // ── Header ──────────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                AppText.h1(AppStrings.emergencyTitle, fontWeight: FontWeight.w800),
                const SizedBox(height: 4),
                AppText.bodyMd(
                  AppStrings.emergencySubtitle,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                AppBadge(label: AppStrings.emergencyBadge, variant: AppBadgeVariant.red),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Section: Emergency info ──────────────────────────────────────
          AppText.labelLg(AppStrings.emergencyInfoSection, color: AppColors.textSecondary),
          
          const SizedBox(height: 14),

          // Date of birth
          AppText.labelMd(AppStrings.dateOfBirth),

          const SizedBox(height: 8),

          AppDobPicker(
            date: _dob,
            onChanged: (d) => setState(() => _dob = d),
          ),

          const SizedBox(height: 12),

          // Chronic conditions
          AppMultiSelectDropdownInput<String>(
            label: AppStrings.chronicConditions,
            options: _kConditionsPresets,
            labels: _kConditionsPresets,
            selected: _conditions,
            hint: AppStrings.selectConditions,
            searchable: true,
            searchHint: AppStrings.searchConditionsHint,
            customItemFactory: (s) => s,
            onChanged: (v) => setState(() => _conditions = v),
          ),

          const SizedBox(height: 12),

          // Allergies
          AppMultiSelectDropdownInput<String>(
            label: AppStrings.knownAllergies,
            options: _kAllergiesPresets,
            labels: _kAllergiesPresets,
            selected: _allergies,
            hint: AppStrings.selectAllergies,
            searchable: true,
            searchHint: AppStrings.searchAllergiesHint,
            customItemFactory: (s) => s,
            onChanged: (v) => setState(() => _allergies = v),
          ),
          const SizedBox(height: 26),

          // ── Section: Emergency contact ───────────────────────────────────
          AppText.labelLg(AppStrings.emergencyContact, color: AppColors.textSecondary),
          const SizedBox(height: 14),

          AppTextField(
            controller: _nameCtrl,
            label: AppStrings.contactName,
            hint: AppStrings.contactName,
            enabled: !_isLoading,
          ),
          
          const SizedBox(height: 12),

          AppPhoneInput(
            controller: _contactPhoneCtrl,
            enabled: !_isLoading,
            onCountryChanged: (region) {
              final country = kCountryCodes.firstWhere(
                (c) => c.region == region,
                orElse: () => kDefaultCountry,
              );
              setState(() => _contactCountry = country);
            },
          ),
          
          const SizedBox(height: 24),

          // ── Error ────────────────────────────────────────────────────────
          if (_error != null) ...[
            Center(
              child: AppText.bodyMd(_error!, color: AppColors.error, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 12),
          ],

          // ── Actions ──────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: AuthButton(
                  label: AppStrings.saveAndContinue,
                  loading: _isLoading,
                  onPressed: _save,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 54,
                child: AppButton(
                  variant: AppButtonVariant.outline,
                  label: AppStrings.skip,
                  color: AppColors.textSecondary,
                  onPressed: _isLoading ? null : widget.onSkip,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Center(
            child: AppText.bodyXs(
              AppStrings.emergencyDataNote,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
