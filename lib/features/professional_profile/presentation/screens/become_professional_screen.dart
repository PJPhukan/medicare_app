import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/connectivity_monitor.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';

// ─── Mock categories ─────────────────────────────────────────────────────────

const _kCategories = [
  (id: 'doctor',       label: 'Doctor'),
  (id: 'nurse',        label: 'Nurse'),
  (id: 'physio',       label: 'Physiotherapist'),
  (id: 'psychologist', label: 'Psychologist'),
  (id: 'dietitian',    label: 'Dietitian'),
  (id: 'pharmacist',   label: 'Pharmacist'),
  (id: 'lab',          label: 'Lab Technician'),
];

// ─── Agreement bullets (matching web BecomeProfessionalPage.tsx exactly) ─────

const _kAgreementBullets = [
  'You are solely responsible for all medical advice, consultations, and services you provide to patients through this platform.',
  'The platform acts only as a marketplace to connect professionals and patients. We hold no liability for the quality, accuracy, or outcomes of your services.',
  'You confirm that all identity documents and qualifications submitted are genuine. Submitting false information may result in immediate removal and legal action.',
  'In case of any dispute between you and a patient, you agree to resolve it directly. The platform is not a party to such disputes.',
  'You will comply with all applicable laws and medical regulations in your region while providing services.',
  'You understand that payments are subject to platform service fees and payout schedules as described in our payment policy.',
];

// ─── Country codes ───────────────────────────────────────────────────────────

const _kCountryCodes = [
  (code: '+91',  name: 'India'),
  (code: '+1',   name: 'USA'),
  (code: '+44',  name: 'UK'),
  (code: '+61',  name: 'Australia'),
  (code: '+971', name: 'UAE'),
];

// ─── Screen ──────────────────────────────────────────────────────────────────

class BecomeProfessionalScreen extends ConsumerStatefulWidget {
  const BecomeProfessionalScreen({super.key, this.isEditing = false});
  final bool isEditing;

  @override
  ConsumerState<BecomeProfessionalScreen> createState() =>
      _BecomeProfessionalScreenState();
}

class _BecomeProfessionalScreenState extends ConsumerState<BecomeProfessionalScreen> {
  int _step = 0;
  bool _submitted = false;

  bool get _isEditing => widget.isEditing;
  int get _totalSteps => _isEditing ? 2 : 3;

  // ── Step 1 ───────────────────────────────────────────────────────────────────
  bool _hasPhoto = false;
  final Set<String> _selectedCats = {};
  final _displayNameCtrl = TextEditingController();
  final _experienceCtrl  = TextEditingController();
  final _basePriceCtrl   = TextEditingController();
  final _hourlyCtrl      = TextEditingController();
  final _dailyCtrl       = TextEditingController();
  final _monthlyCtrl     = TextEditingController();
  final _bioCtrl         = TextEditingController();
  final _addressCtrl     = TextEditingController();
  String _currency = 'INR';

  // ── Step 2 ───────────────────────────────────────────────────────────────────
  String _countryCode = '+91';
  final _phoneCtrl   = TextEditingController();
  final _aadhaarCtrl = TextEditingController();
  final _panCtrl     = TextEditingController();
  bool _hasPanFront     = false;
  bool _hasPanBack      = false;
  bool _hasAadhaarFront = false;
  bool _hasAadhaarBack  = false;
  final List<String> _certs = [];
  final _certCtrl = TextEditingController();

  // ── Step 3 ───────────────────────────────────────────────────────────────────
  bool _agreed = false;

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _experienceCtrl.dispose();
    _basePriceCtrl.dispose();
    _hourlyCtrl.dispose();
    _dailyCtrl.dispose();
    _monthlyCtrl.dispose();
    _bioCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _aadhaarCtrl.dispose();
    _panCtrl.dispose();
    _certCtrl.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────────

  String? _validateStep() {
    switch (_step) {
      case 0:
        if (_selectedCats.isEmpty) return AppStrings.categoryRequired;
        return null;
      case 1:
        final phone = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
        if (phone.length != 10) return AppStrings.invalidPhone;
        final aadhaar = _aadhaarCtrl.text.replaceAll(' ', '');
        if (aadhaar.length != 12 || int.tryParse(aadhaar) == null) {
          return AppStrings.invalidAadhaar;
        }
        final pan = _panCtrl.text.toUpperCase();
        if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(pan)) {
          return AppStrings.invalidPan;
        }
        if (!_hasPanFront || !_hasPanBack || !_hasAadhaarFront || !_hasAadhaarBack) {
          return AppStrings.allImagesRequired;
        }
        return null;
      case 2:
        if (!_agreed) return AppStrings.pleaseAgreeToTerms;
        return null;
    }
    return null;
  }

  void _advance() {
    final err = _validateStep();
    if (err != null) {
      AppSnackbar.error(context, err);
      return;
    }
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      setState(() => _submitted = true);
    }
  }

  void _goBack() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _jumpToStep(int i) {
    if (i < _step) setState(() => _step = i);
  }

  void _addCert() {
    final v = _certCtrl.text.trim();
    if (v.isEmpty) return;
    if (_certs.length >= 10) {
      AppSnackbar.error(context, AppStrings.maxCertificationsReached);
      return;
    }
    setState(() => _certs.add(v));
    _certCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Professional Profile');
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.bg,
          elevation: 0,
          leading: _submitted
              ? const SizedBox.shrink()
              : IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: context.primaryText, size: 20),
                  onPressed: _goBack,
                ),
          title: Text(_isEditing ? AppStrings.editProfessionalProfile : AppStrings.becomeProfessional,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          centerTitle: true,
        ),
        body: _submitted ? _buildSubmitted() : _buildWizard(),
      ),
    );
  }

  // ── Submitted ─────────────────────────────────────────────────────────────────

  Widget _buildSubmitted() {
    final isEdit = _isEditing;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: isEdit
                    ? AppColors.teal.withValues(alpha: 0.12)
                    : AppColors.amber.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEdit ? Icons.check_rounded : Icons.hourglass_top_rounded,
                color: isEdit ? AppColors.teal : AppColors.amber,
                size: 44,
              ),
            ),
            const SizedBox(height: 24),
            AppText.h2(
              isEdit ? AppStrings.profileUpdated : AppStrings.applicationSubmitted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            AppText.bodySm(
              isEdit ? AppStrings.profileUpdatedDesc : AppStrings.applicationPendingDesc,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: AppColors.textInverse,
                  shape: RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.lgAll),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(AppStrings.back, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Wizard ────────────────────────────────────────────────────────────────────

  Widget _buildWizard() {
    return Column(
      children: [
        _StepIndicator(currentStep: _step, totalSteps: _totalSteps),
        _StepTabPills(currentStep: _step, totalSteps: _totalSteps, onTap: _jumpToStep),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(_step),
                child: _currentStepWidget(),
              ),
            ),
          ),
        ),
        _NavBar(
          step: _step,
          totalSteps: _totalSteps,
          submitLabel: _isEditing ? AppStrings.saveChanges : AppStrings.submit,
          onBack: _goBack,
          onAdvance: _advance,
        ),
      ],
    );
  }

  Widget _currentStepWidget() {
    switch (_step) {
      case 0:  return _buildStep1();
      case 1:  return _buildStep2();
      default: return _buildStep3();
    }
  }

  // ── Step 1: Profile ────────────────────────────────────────────────────────────

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PhotoPicker(
          hasPhoto: _hasPhoto,
          onTap: () => setState(() => _hasPhoto = !_hasPhoto),
        ),
        const SizedBox(height: 28),
        _WizLabel(AppStrings.selectCategories),
        const SizedBox(height: 10),
        _CategoryChips(
          categories: _kCategories,
          selected: _selectedCats,
          onToggle: (id) => setState(() {
            if (_selectedCats.contains(id)) {
              _selectedCats.remove(id);
            } else {
              _selectedCats.add(id);
            }
          }),
        ),
        const SizedBox(height: 24),
        _WizLabel(AppStrings.displayName),
        const SizedBox(height: 8),
        _WizField(
          controller: _displayNameCtrl,
          hint: AppStrings.displayNameHint,
          icon: Icons.badge_rounded,
        ),
        const SizedBox(height: 20),
        _WizLabel(AppStrings.proExperience),
        const SizedBox(height: 8),
        _WizField(
          controller: _experienceCtrl,
          hint: AppStrings.experienceHint,
          icon: Icons.military_tech_rounded,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 20),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _WizLabel(AppStrings.basePrice),
              const SizedBox(height: 8),
              _WizField(
                controller: _basePriceCtrl,
                hint: AppStrings.basePriceHint,
                icon: Icons.payments_rounded,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ]),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _WizLabel(AppStrings.currency),
            const SizedBox(height: 8),
            _CurrencyPicker(
              value: _currency,
              onChanged: (v) => setState(() => _currency = v),
            ),
          ]),
        ]),
        const SizedBox(height: 28),
        AppText.labelMd(AppStrings.connectionRates, color: context.primaryText),
        const SizedBox(height: 4),
        AppText.bodyXs(AppStrings.connectionRatesSubtitle, color: AppColors.textSecondary),
        const SizedBox(height: 16),
        _WizLabel(AppStrings.hourlyRate),
        const SizedBox(height: 8),
        _WizField(
          controller: _hourlyCtrl,
          hint: AppStrings.basePriceHint,
          icon: Icons.access_time_rounded,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 20),
        _WizLabel(AppStrings.dailyRate),
        const SizedBox(height: 8),
        _WizField(
          controller: _dailyCtrl,
          hint: AppStrings.basePriceHint,
          icon: Icons.today_rounded,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 20),
        _WizLabel(AppStrings.monthlyRate),
        const SizedBox(height: 8),
        _WizField(
          controller: _monthlyCtrl,
          hint: AppStrings.basePriceHint,
          icon: Icons.calendar_month_rounded,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 20),
        _WizLabel(AppStrings.bio),
        const SizedBox(height: 8),
        _WizField(
          controller: _bioCtrl,
          hint: AppStrings.bioHint,
          icon: Icons.notes_rounded,
          maxLines: 4,
          maxLength: 1000,
        ),
        const SizedBox(height: 20),
        _WizLabel(AppStrings.address),
        const SizedBox(height: 8),
        _WizField(
          controller: _addressCtrl,
          hint: AppStrings.addressHint,
          icon: Icons.location_on_rounded,
          maxLines: 2,
          maxLength: 300,
        ),
      ],
    );
  }

  // ── Step 2: Documents ──────────────────────────────────────────────────────────

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SecurityBanner(),
        const SizedBox(height: 24),
        _WizLabel(AppStrings.phone),
        const SizedBox(height: 8),
        _PhoneField(
          countryCode: _countryCode,
          controller: _phoneCtrl,
          onPickCode: _showCountryCodePicker,
        ),
        const SizedBox(height: 20),
        _WizLabel(AppStrings.aadhaarNumber),
        const SizedBox(height: 8),
        _WizField(
          controller: _aadhaarCtrl,
          hint: AppStrings.aadhaarHint,
          icon: Icons.credit_card_rounded,
          keyboardType: TextInputType.number,
          inputFormatters: [_AadhaarFormatter()],
          maxLength: 14,
        ),
        const SizedBox(height: 20),
        _WizLabel(AppStrings.panNumber),
        const SizedBox(height: 8),
        _WizField(
          controller: _panCtrl,
          hint: AppStrings.panHint,
          icon: Icons.badge_rounded,
          maxLength: 10,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            _UpperCaseFormatter(),
          ],
        ),
        const SizedBox(height: 24),
        _WizLabel('Identity Documents'),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _ImagePickerBox(
              label: AppStrings.panFront,
              icon: Icons.credit_card_rounded,
              color: AppColors.blue,
              selected: _hasPanFront,
              onTap: () => setState(() => _hasPanFront = !_hasPanFront),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ImagePickerBox(
              label: AppStrings.panBack,
              icon: Icons.flip_rounded,
              color: AppColors.blue,
              selected: _hasPanBack,
              onTap: () => setState(() => _hasPanBack = !_hasPanBack),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _ImagePickerBox(
              label: AppStrings.aadhaarFront,
              icon: Icons.person_pin_rounded,
              color: AppColors.purple,
              selected: _hasAadhaarFront,
              onTap: () =>
                  setState(() => _hasAadhaarFront = !_hasAadhaarFront),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ImagePickerBox(
              label: AppStrings.aadhaarBack,
              icon: Icons.flip_rounded,
              color: AppColors.purple,
              selected: _hasAadhaarBack,
              onTap: () =>
                  setState(() => _hasAadhaarBack = !_hasAadhaarBack),
            ),
          ),
        ]),
        const SizedBox(height: 28),
        _CertificationsSection(
          certs: _certs,
          certCtrl: _certCtrl,
          onAdd: _addCert,
          onRemove: (i) => setState(() => _certs.removeAt(i)),
        ),
      ],
    );
  }

  void _showCountryCodePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.topXxl,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: context.dividerCol,
                  borderRadius: AppBorderRadius.pill,
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppText.h3(AppStrings.selectCountry),
            const SizedBox(height: 12),
            ..._kCountryCodes.map((c) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: AppText.bodyMd(c.name, color: context.primaryText),
              trailing: AppText.bodyMd(c.code, color: AppColors.teal),
              onTap: () {
                setState(() => _countryCode = c.code);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  // ── Step 3: Agreement ──────────────────────────────────────────────────────────

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.agreementTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(AppStrings.agreementPreamble,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.6)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: context.borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _kAgreementBullets.map((bullet) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.teal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(bullet,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.6)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Text(AppStrings.agreementFooter,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.6, fontStyle: FontStyle.italic)),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => setState(() => _agreed = !_agreed),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _agreed ? AppColors.teal : context.inputBg,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: _agreed ? AppColors.teal : context.dividerCol,
                    width: 2,
                  ),
                ),
                child: _agreed
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.textInverse, size: 14)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(AppStrings.agreementCheckbox,
                    style: TextStyle(fontSize: 14, color: context.primaryText, height: 1.5)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Navigation Bar ──────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.step,
    required this.totalSteps,
    required this.submitLabel,
    required this.onBack,
    required this.onAdvance,
  });
  final int step;
  final int totalSteps;
  final String submitLabel;
  final VoidCallback onBack;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 12 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border(top: BorderSide(color: context.borderCol)),
      ),
      child: Row(children: [
        if (step > 0) ...[
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.primaryText,
                  side: BorderSide(color: context.borderCol),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.lgAll),
                ),
                onPressed: onBack,
                child:
                    const Text(AppStrings.back, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: step > 0 ? 2 : 1,
          child: SizedBox(
            height: 50,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: AppColors.textInverse,
                shape: RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.lgAll),
              ),
              onPressed: onAdvance,
              child: Text(
                step < totalSteps - 1 ? AppStrings.next : submitLabel,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Step Tab Pills ───────────────────────────────────────────────────────────

class _StepTabPills extends StatelessWidget {
  const _StepTabPills({
    required this.currentStep,
    required this.totalSteps,
    required this.onTap,
  });
  final int currentStep;
  final int totalSteps;
  final ValueChanged<int> onTap;

  static const _labels = [
    AppStrings.stepProfile,
    AppStrings.stepDocuments,
    AppStrings.stepAgreement,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      color: context.bg,
      child: Row(
        children: List.generate(totalSteps, (i) {
          final active = i == currentStep;
          final done = i < currentStep;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.teal
                      : done
                          ? AppColors.teal.withValues(alpha: 0.15)
                          : context.inputBg,
                  borderRadius: AppBorderRadius.pill,
                  border: Border.all(
                    color: active || done
                        ? AppColors.teal
                        : context.borderCol,
                  ),
                ),
                child: Text(
                  _labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.5,
                    color: active
                        ? AppColors.textInverse
                        : done
                            ? AppColors.teal
                            : AppColors.textSecondary,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Step Indicator ──────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep, required this.totalSteps});
  final int currentStep;
  final int totalSteps;

  static const _labels = [
    AppStrings.stepProfile,
    AppStrings.stepDocuments,
    AppStrings.stepAgreement,
  ];
  static const _icons = [
    Icons.person_rounded,
    Icons.folder_rounded,
    Icons.shield_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      color: context.bg,
      child: Column(
        children: [
          Row(
            children: List.generate(totalSteps, (i) {
              final done   = i < currentStep;
              final active = i == currentStep;
              return Expanded(
                child: Center(
                  child: _StepCircle(
                      index: i, done: done, active: active, icon: _icons[i]),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(totalSteps, (i) {
              final active = i == currentStep;
              final done   = i < currentStep;
              final lastIdx = totalSteps - 1;
              return Expanded(
                child: Text(
                  _labels[i],
                  textAlign: i == 0
                      ? TextAlign.start
                      : i == lastIdx
                          ? TextAlign.end
                          : TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.5,
                    color: done
                        ? AppColors.teal
                        : active
                            ? context.primaryText
                            : AppColors.textSecondary,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle(
      {required this.index,
      required this.done,
      required this.active,
      required this.icon});
  final int index;
  final bool done;
  final bool active;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final Color bg = done
        ? AppColors.teal
        : active
            ? AppColors.teal.withValues(alpha: 0.15)
            : context.inputBg;
    final Color border = done || active ? AppColors.teal : context.dividerCol;
    final Color fg = done
        ? AppColors.textInverse
        : active
            ? AppColors.teal
            : AppColors.textSecondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2),
      ),
      child: done
          ? const Icon(Icons.check_rounded, color: AppColors.textInverse, size: 18)
          : Icon(icon, color: fg, size: 18),
    );
  }
}

// ─── Photo Picker ─────────────────────────────────────────────────────────────

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.hasPhoto, required this.onTap});
  final bool hasPhoto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: context.inputBg,
                border: Border.all(
                  color: hasPhoto ? AppColors.teal : context.borderCol,
                  width: 2,
                ),
              ),
              child: hasPhoto
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: const Icon(Icons.person_rounded,
                          color: AppColors.teal, size: 48),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_rounded,
                            color: AppColors.textHint, size: 30),
                        const SizedBox(height: 4),
                        AppText.bodyXs('Upload Photo', color: AppColors.textHint),
                      ],
                    ),
            ),
            if (hasPhoto)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.bg, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: AppColors.textInverse, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Category Chips ───────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  const _CategoryChips(
      {required this.categories,
      required this.selected,
      required this.onToggle});
  final List<({String id, String label})> categories;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 112),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.inputBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((cat) {
              final on = selected.contains(cat.id);
              return GestureDetector(
                onTap: () => onToggle(cat.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: on
                        ? AppColors.teal.withValues(alpha: 0.15)
                        : context.cardBg,
                    border: Border.all(
                        color: on ? AppColors.teal : context.borderCol),
                    borderRadius: AppBorderRadius.pill,
                  ),
                  child: AppText.labelMd(cat.label,
                      color: on ? AppColors.teal : AppColors.textSecondary),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Security Banner ──────────────────────────────────────────────────────────

class _SecurityBanner extends StatelessWidget {
  const _SecurityBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.1),
        borderRadius: AppBorderRadius.lgAll,
        border:
            Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.lock_rounded, color: AppColors.amber, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: AppText.bodySm(AppStrings.secureDataBanner, color: AppColors.amber),
        ),
      ]),
    );
  }
}

// ─── Phone Field ─────────────────────────────────────────────────────────────

class _PhoneField extends StatelessWidget {
  const _PhoneField(
      {required this.countryCode,
      required this.controller,
      required this.onPickCode});
  final String countryCode;
  final TextEditingController controller;
  final VoidCallback onPickCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.inputBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: context.borderCol),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: onPickCode,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: context.borderCol)),
            ),
            child: Row(children: [
              AppText.bodyMd(countryCode, color: context.primaryText),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more_rounded,
                  color: AppColors.textSecondary, size: 16),
            ]),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            style: TextStyle(fontSize: 14, color: context.primaryText),
            decoration: InputDecoration(
              hintText: AppStrings.enterPhoneNumber,
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Image Picker Box ────────────────────────────────────────────────────────

class _ImagePickerBox extends StatelessWidget {
  const _ImagePickerBox(
      {required this.label,
      required this.icon,
      required this.color,
      required this.selected,
      required this.onTap});
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 104,
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.12)
              : context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(
            color: selected ? color : context.borderCol,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : icon,
              color: selected ? color : AppColors.textHint,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: selected ? color : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center),
            if (!selected) ...[
              const SizedBox(height: 2),
              AppText.bodyXs(AppStrings.tapToSelect, color: AppColors.textHint),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Certifications Section ───────────────────────────────────────────────────

class _CertificationsSection extends StatelessWidget {
  const _CertificationsSection({
    required this.certs,
    required this.certCtrl,
    required this.onAdd,
    required this.onRemove,
  });
  final List<String> certs;
  final TextEditingController certCtrl;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WizLabel('${AppStrings.certifications} (${certs.length}/10)'),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: _WizField(
              controller: certCtrl,
              hint: AppStrings.certificationHint,
              icon: Icons.workspace_premium_rounded,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: AppBorderRadius.lgAll,
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.textInverse, size: 24),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        if (certs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: AppBorderRadius.lgAll,
              border: Border.all(color: context.borderCol),
            ),
            child: AppText.bodySm(AppStrings.noCertificationsYet,
                color: AppColors.textHint,
                textAlign: TextAlign.center),
          )
        else
          ...certs.asMap().entries.map(
                (e) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: AppBorderRadius.lgAll,
                    border: Border.all(color: context.borderCol),
                  ),
                  child: Row(children: [
                    const Icon(Icons.workspace_premium_rounded,
                        color: AppColors.amber, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppText.bodyMd(e.value, color: context.primaryText),
                    ),
                    GestureDetector(
                      onTap: () => onRemove(e.key),
                      child: const Icon(Icons.close_rounded,
                          color: AppColors.textSecondary, size: 18),
                    ),
                  ]),
                ),
              ),
      ],
    );
  }
}

// ─── Currency Picker ─────────────────────────────────────────────────────────

class _CurrencyPicker extends StatelessWidget {
  const _CurrencyPicker({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  static const _currencies = ['INR', 'USD', 'EUR', 'GBP'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => Container(
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: AppBorderRadius.topXxl,
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: context.dividerCol,
                  borderRadius: AppBorderRadius.pill,
                ),
              ),
              const SizedBox(height: 16),
              AppText.h3(AppStrings.currency),
              const SizedBox(height: 12),
              ..._currencies.map((c) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: AppText.bodyMd(c, color: context.primaryText),
                trailing: c == value
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.teal)
                    : null,
                onTap: () {
                  onChanged(c);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        ),
      ),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: context.inputBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          AppText.bodyMd(value, color: context.primaryText),
          const SizedBox(width: 4),
          const Icon(Icons.expand_more_rounded,
              color: AppColors.textSecondary, size: 16),
        ]),
      ),
    );
  }
}

// ─── Shared form helpers ──────────────────────────────────────────────────────

class _WizLabel extends StatelessWidget {
  const _WizLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return AppText.labelMd(text, color: AppColors.textSecondary);
  }
}

class _WizField extends StatelessWidget {
  const _WizField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      style: TextStyle(fontSize: 14, color: context.primaryText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        filled: true,
        fillColor: context.inputBg,
        counterStyle: const TextStyle(fontSize: 11, color: AppColors.textHint),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.lgAll,
          borderSide: BorderSide(color: context.borderCol),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.lgAll,
          borderSide: const BorderSide(color: AppColors.teal),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

// ─── Input formatters ────────────────────────────────────────────────────────

class _AadhaarFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 12) return oldValue;
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 4 || i == 8) buf.write(' ');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
