import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/connectivity_monitor.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/pro_profile_provider.dart';
import '../../../professionals/presentation/providers/professionals_provider.dart';
import 'service_areas_screen.dart';
import '../../domain/entities/pro_profile_entity.dart';

// ─── Agreement bullets (matching web BecomeProfessionalPage.tsx exactly) ─────

const _kAgreementBullets = [
  'You are solely responsible for all medical advice, consultations, and services you provide to patients through this platform.',
  'The platform acts only as a marketplace to connect professionals and patients. We hold no liability for the quality, accuracy, or outcomes of your services.',
  'You confirm that all identity documents and qualifications submitted are genuine. Submitting false information may result in immediate removal and legal action.',
  'In case of any dispute between you and a patient, you agree to resolve it directly. The platform is not a party to such disputes.',
  'You will comply with all applicable laws and medical regulations in your region while providing services.',
  'You understand that payments are subject to platform service fees and payout schedules as described in our payment policy.',
];

// ─── Screen ──────────────────────────────────────────────────────────────────

class BecomeProfessionalScreen extends ConsumerStatefulWidget {
  const BecomeProfessionalScreen({super.key, this.isEditing = false});
  final bool isEditing;

  @override
  ConsumerState<BecomeProfessionalScreen> createState() =>
      _BecomeProfessionalScreenState();
}

class _BecomeProfessionalScreenState
    extends ConsumerState<BecomeProfessionalScreen> {
  int _step = 0;
  bool _submitted = false;

  bool get _isEditing => widget.isEditing;
  int get _totalSteps => _isEditing ? 2 : 3;

  // ── Step 1 ───────────────────────────────────────────────────────────────────
  final List<String> _selectedCats = [];
  final _displayNameCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _basePriceCtrl = TextEditingController();
  final _hourlyCtrl = TextEditingController();
  final _dailyCtrl = TextEditingController();
  final _monthlyCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _currency = 'INR';

  final _PickedImage _photo = _PickedImage();

  // ── Step 2 ───────────────────────────────────────────────────────────────────
  final _phoneCtrl = TextEditingController();
  final _aadhaarCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  final _PickedImage _panFront = _PickedImage();
  final _PickedImage _panBack = _PickedImage();
  final _PickedImage _aadhaarFront = _PickedImage();
  final _PickedImage _aadhaarBack = _PickedImage();
  final List<String> _certs = [];
  final _certCtrl = TextEditingController();

  // ── Step 3 ───────────────────────────────────────────────────────────────────
  bool _agreed = false;
  bool _submitting = false;
  bool _prefilled = false;

  // Pre-fill the editable details from the existing profile (edit mode).
  void _prefill(ProProfileEntity p) {
    _prefilled = true;
    _displayNameCtrl.text = p.displayName ?? '';
    _bioCtrl.text = p.bio ?? '';
    _experienceCtrl.text = p.experienceYrs?.toString() ?? '';
    _basePriceCtrl.text = p.basePrice?.toStringAsFixed(0) ?? '';
    _hourlyCtrl.text = p.hourlyRate?.toStringAsFixed(0) ?? '';
    _dailyCtrl.text = p.dailyRate?.toStringAsFixed(0) ?? '';
    _monthlyCtrl.text = p.monthlyRate?.toStringAsFixed(0) ?? '';
    _addressCtrl.text = p.address ?? '';
    if (p.phone != null) {
      final digits = p.phone!.replaceAll(RegExp(r'\D'), '');
      _phoneCtrl.text =
          digits.length > 10 ? digits.substring(digits.length - 10) : digits;
    }
    _currency = p.currency ?? 'INR';
    _selectedCats.clear();
    if (p.categoryId != null) _selectedCats.add(p.categoryId!);
    _certs
      ..clear()
      ..addAll(p.certifications);
    _photo.existingUrl = p.profileImageUrl;
    _agreed = p.agreedToTerms;
    setState(() {});
  }

  // Pick an image from the gallery, downscale, and keep its base64 data URL.
  Future<void> _pickInto(_PickedImage target) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      imageQuality: 75,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      target.bytes = bytes;
      target.dataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    });
  }

  void _clearImage(_PickedImage target) => setState(() {
        target.bytes = null;
        target.dataUrl = null;
        target.existingUrl = null;
      });

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
        final pan = _panCtrl.text.toUpperCase();
        // In edit mode KYC was already submitted (and isn't returned to the
        // client), so only validate fields the user actually re-entered.
        if (!_isEditing || aadhaar.isNotEmpty) {
          if (aadhaar.length != 12 || int.tryParse(aadhaar) == null) {
            return AppStrings.invalidAadhaar;
          }
        }
        if (!_isEditing || pan.isNotEmpty) {
          if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(pan)) {
            return AppStrings.invalidPan;
          }
        }
        if (!_isEditing &&
            (!_panFront.isSet ||
                !_panBack.isSet ||
                !_aadhaarFront.isSet ||
                !_aadhaarBack.isSet)) {
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
      _submit();
    }
  }

  int? _intOf(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : int.tryParse(t);
  }

  Map<String, dynamic> _buildPayload() {
    final phone = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    return {
      'categoryIds': _selectedCats,
      if (_displayNameCtrl.text.trim().isNotEmpty)
        'displayName': _displayNameCtrl.text.trim(),
      if (_bioCtrl.text.trim().isNotEmpty) 'bio': _bioCtrl.text.trim(),
      if (_intOf(_experienceCtrl) != null) 'experienceYrs': _intOf(_experienceCtrl),
      if (_intOf(_basePriceCtrl) != null) 'basePrice': _intOf(_basePriceCtrl),
      if (_intOf(_hourlyCtrl) != null) 'hourlyRate': _intOf(_hourlyCtrl),
      if (_intOf(_dailyCtrl) != null) 'dailyRate': _intOf(_dailyCtrl),
      if (_intOf(_monthlyCtrl) != null) 'monthlyRate': _intOf(_monthlyCtrl),
      'currency': _currency,
      if (phone.length == 10) 'phone': '+91$phone',
      if (_addressCtrl.text.trim().isNotEmpty) 'address': _addressCtrl.text.trim(),
      // KYC numbers: only send when entered (blank in edit mode = leave as-is).
      if (_aadhaarCtrl.text.replaceAll(' ', '').isNotEmpty)
        'aadhaarNumber': _aadhaarCtrl.text.replaceAll(' ', ''),
      if (_panCtrl.text.trim().isNotEmpty) 'panNumber': _panCtrl.text.toUpperCase().trim(),
      // Images: only send a newly picked one (dataUrl); never overwrite with null.
      if (_photo.dataUrl != null) 'profileImageUrl': _photo.dataUrl,
      if (_panFront.dataUrl != null) 'panFrontUrl': _panFront.dataUrl,
      if (_panBack.dataUrl != null) 'panBackUrl': _panBack.dataUrl,
      if (_aadhaarFront.dataUrl != null) 'aadhaarFrontUrl': _aadhaarFront.dataUrl,
      if (_aadhaarBack.dataUrl != null) 'aadhaarBackUrl': _aadhaarBack.dataUrl,
      if (_certs.isNotEmpty) 'certifications': _certs,
      // Only sent on create. Re-sending true on edit would re-trigger the
      // backend's KYC-required gate even though we aren't resubmitting docs.
      if (!_isEditing) 'agreedToTerms': _agreed,
    };
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(proProfileProvider.notifier)
          .submit(_buildPayload(), isEditing: _isEditing);
      if (!mounted) return;
      setState(() => _submitted = true);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Could not submit profile. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _goBack() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.of(context).pop();
    }
  }

  // Submit a speciality that isn't in the list; it goes to admin for approval
  // but can be selected immediately.
  Future<void> _addCustomCategory() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardBg,
        title: AppText.h3('Add a speciality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.bodyXs(
              "We'll send it for verification — you can use it right away.",
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: ctrl,
              hint: 'e.g. Lactation Consultant',
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: AppText.labelMd('Cancel', color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: AppText.labelMd('Submit', color: AppColors.teal),
          ),
        ],
      ),
    );
    if (name == null || name.length < 2) return;

    final id = await ref
        .read(professionalsProvider.notifier)
        .requestCustomCategory(name);
    if (!mounted) return;
    if (id != null) {
      setState(() {
        if (!_selectedCats.contains(id)) _selectedCats.add(id);
      });
      AppSnackbar.success(context, 'Speciality submitted — you can use it now');
    } else {
      AppSnackbar.error(context, 'Could not submit. Please try again.');
    }
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

  void _openServiceAreas() => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ServiceAreasScreen()),
      );

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Professional Profile');
    }
    final proState = ref.watch(proProfileProvider);

    // Edit mode: pre-fill once the existing profile is available.
    if (_isEditing && !_prefilled) {
      final existing = proState.profile;
      if (existing != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_prefilled) _prefill(existing);
        });
      }
    }

    // Apply mode but a profile already exists → show its status, not the form.
    final existingProfile = proState.profile;
    final showStatus = !_isEditing && !_submitted && existingProfile != null;
    final loadingProfile =
        !_isEditing && !_submitted && proState.isLoading && existingProfile == null;

    final Widget body;
    if (_submitted) {
      body = _buildSubmitted();
    } else if (loadingProfile) {
      body = const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal),
      );
    } else if (showStatus) {
      body = _buildStatus(existingProfile.isVerified);
    } else {
      body = _buildWizard();
    }
    final hideBack = _submitted;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.bg,
          elevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 76,
          leading: hideBack
              ? const SizedBox.shrink()
              : IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: context.primaryText, size: 20),
                  onPressed: _goBack,
                ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing
                    ? AppStrings.editProfessionalProfile
                    : showStatus
                        ? 'Professional Profile'
                        : AppStrings.becomeProfessional,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                _isEditing
                    ? 'Update your professional details and save the changes below.'
                    : showStatus
                        ? 'Your application status and setup.'
                        : 'Complete your professional details below to create your profile.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.2,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          centerTitle: false,
        ),
        body: body,
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
              isEdit
                  ? AppStrings.profileUpdated
                  : AppStrings.applicationSubmitted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            AppText.bodySm(
              isEdit
                  ? AppStrings.profileUpdatedDesc
                  : AppStrings.applicationPendingDesc,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton.primary(
              label: 'Set up Service Areas',
              onPressed: _openServiceAreas,
              size: AppButtonSize.lg,
              isFullWidth: true,
            ),
            const SizedBox(height: 12),
            AppButton.secondary(
              label: AppStrings.back,
              onPressed: () => Navigator.of(context).pop(),
              size: AppButtonSize.lg,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  // ── Already-applied status (shown if user re-opens "Become a Professional") ───

  Widget _buildStatus(bool verified) {
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
                color: (verified ? AppColors.teal : AppColors.amber)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                verified ? Icons.verified_rounded : Icons.hourglass_top_rounded,
                color: verified ? AppColors.teal : AppColors.amber,
                size: 44,
              ),
            ),
            const SizedBox(height: 24),
            AppText.h2(
              verified ? "You're verified" : 'Under review',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            AppText.bodySm(
              verified
                  ? 'Your professional profile is live. Patients can now find and connect with you.'
                  : "Your application has been submitted and is awaiting verification. We'll notify you once it's approved.",
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton.primary(
              label: 'Manage Service Areas',
              onPressed: _openServiceAreas,
              size: AppButtonSize.lg,
              isFullWidth: true,
            ),
            const SizedBox(height: 12),
            AppButton.secondary(
              label: AppStrings.back,
              onPressed: () => Navigator.of(context).pop(),
              size: AppButtonSize.lg,
              isFullWidth: true,
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
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
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
          isBusy: _submitting,
        ),
      ],
    );
  }

  Widget _currentStepWidget() {
    switch (_step) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      default:
        return _buildStep3();
    }
  }

  // ── Step 1: Profile ────────────────────────────────────────────────────────────

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          hasShadow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.12),
                      borderRadius: AppBorderRadius.mdAll,
                    ),
                    child: const Icon(Icons.workspace_premium_rounded,
                        color: AppColors.teal, size: 19),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.labelMd(AppStrings.becomeProfessional,
                            color: context.primaryText),
                        AppText.bodyXs('Your basic professional details',
                            color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _displayNameCtrl,
                label: AppStrings.displayName,
                hint: AppStrings.displayNameHint,
                prefix: const Icon(Icons.badge_rounded),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _experienceCtrl,
                      label: AppStrings.proExperience,
                      hint: AppStrings.experienceHint,
                      prefix: const Icon(Icons.military_tech_rounded),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 14),
                  _ProfilePhotoField(
                    bytes: _photo.bytes,
                    imageUrl: _photo.existingUrl,
                    onTap: () => _pickInto(_photo),
                    onClear: _photo.isSet ? () => _clearImage(_photo) : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Builder(builder: (_) {
                final cats = ref.watch(professionalsProvider).categories;
                return AppMultiSelectDropdownInput<String>(
                  options: cats.map((c) => c.id).toList(),
                  labels: cats.map((c) => c.name).toList(),
                  selected: _selectedCats,
                  label: AppStrings.selectCategories,
                  hint: cats.isEmpty
                      ? 'Loading specialities…'
                      : 'Select your specialities',
                  onChanged: (values) => setState(() => _selectedCats
                    ..clear()
                    ..addAll(values)),
                );
              }),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _addCustomCategory,
                child: Row(children: [
                  const Icon(Icons.add_circle_outline_rounded,
                      size: 16, color: AppColors.teal),
                  const SizedBox(width: 6),
                  Expanded(
                    child: AppText.bodySm(
                      "Can't find your speciality? Add a custom one",
                      color: AppColors.teal,
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          hasShadow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.12),
                      borderRadius: AppBorderRadius.mdAll,
                    ),
                    child: const Icon(Icons.payments_rounded,
                        color: AppColors.green, size: 19),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.labelMd(AppStrings.connectionRates,
                            color: context.primaryText),
                        AppText.bodyXs(AppStrings.connectionRatesSubtitle,
                            color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: AppTextField(
                    controller: _basePriceCtrl,
                    label: AppStrings.basePrice,
                    hint: AppStrings.basePriceHint,
                    prefix: const Icon(Icons.payments_rounded),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDropdownInput<String>(
                    label: AppStrings.currency,
                    hint: 'Select currency',
                    value: _currency,
                    options: const ['INR', 'USD', 'EUR', 'GBP'],
                    labels: const ['INR', 'USD', 'EUR', 'GBP'],
                    onChanged: (v) {
                      setState(() => _currency = v);
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              AppTextField(
                controller: _hourlyCtrl,
                label: AppStrings.hourlyRate,
                hint: AppStrings.basePriceHint,
                prefix: const Icon(Icons.access_time_rounded),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _dailyCtrl,
                label: AppStrings.dailyRate,
                hint: AppStrings.basePriceHint,
                prefix: const Icon(Icons.today_rounded),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _monthlyCtrl,
                label: AppStrings.monthlyRate,
                hint: AppStrings.basePriceHint,
                prefix: const Icon(Icons.calendar_month_rounded),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          hasShadow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.12),
                      borderRadius: AppBorderRadius.mdAll,
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: AppColors.blue, size: 19),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.labelMd(AppStrings.bio,
                            color: context.primaryText),
                        AppText.bodyXs('Tell patients about yourself',
                            color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _bioCtrl,
                label: AppStrings.bio,
                hint: AppStrings.bioHint,
                prefix: const Icon(Icons.notes_rounded),
                maxLines: 4,
                maxLength: 1000,
              ),
              const SizedBox(height: 16),
              AppTextArea(
                controller: _addressCtrl,
                label: AppStrings.address,
                hint: AppStrings.addressHint,
                minLines: 2,
                maxLines: 2,
                maxLength: 300,
              ),
            ],
          ),
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
        AppPhoneField(
          controller: _phoneCtrl,
          label: AppStrings.phone,
          hint: AppStrings.enterPhoneNumber,
        ),
        const SizedBox(height: 20),
        AppTextField(
          controller: _aadhaarCtrl,
          label: AppStrings.aadhaarNumber,
          hint: AppStrings.aadhaarHint,
          prefix: const Icon(Icons.credit_card_rounded),
          keyboardType: TextInputType.number,
          inputFormatters: [_AadhaarFormatter()],
          maxLength: 14,
        ),
        const SizedBox(height: 20),
        AppTextField(
          controller: _panCtrl,
          label: AppStrings.panNumber,
          hint: AppStrings.panHint,
          prefix: const Icon(Icons.badge_rounded),
          maxLength: 10,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            _UpperCaseFormatter(),
          ],
        ),
        const SizedBox(height: 24),
        AppText.labelMd('Identity Documents', color: AppColors.textSecondary),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _ImagePickerBox(
              label: AppStrings.panFront,
              icon: Icons.credit_card_rounded,
              color: AppColors.blue,
              imageBytes: _panFront.bytes,
              onTap: () => _pickInto(_panFront),
              onClear: _panFront.isSet ? () => _clearImage(_panFront) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ImagePickerBox(
              label: AppStrings.panBack,
              icon: Icons.flip_rounded,
              color: AppColors.blue,
              imageBytes: _panBack.bytes,
              onTap: () => _pickInto(_panBack),
              onClear: _panBack.isSet ? () => _clearImage(_panBack) : null,
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
              imageBytes: _aadhaarFront.bytes,
              onTap: () => _pickInto(_aadhaarFront),
              onClear: _aadhaarFront.isSet ? () => _clearImage(_aadhaarFront) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ImagePickerBox(
              label: AppStrings.aadhaarBack,
              icon: Icons.flip_rounded,
              color: AppColors.purple,
              imageBytes: _aadhaarBack.bytes,
              onTap: () => _pickInto(_aadhaarBack),
              onClear: _aadhaarBack.isSet ? () => _clearImage(_aadhaarBack) : null,
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

  // ── Step 3: Agreement ──────────────────────────────────────────────────────────

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.h2(AppStrings.agreementTitle),
        const SizedBox(height: 8),
        AppText.bodySm(
          AppStrings.agreementPreamble,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(20),
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
                      child: AppText.bodySm(
                        bullet,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        AppText.bodySm(
          AppStrings.agreementFooter,
          color: AppColors.textSecondary,
        ),
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
                    style: TextStyle(
                        fontSize: 14, color: context.primaryText, height: 1.5)),
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
    this.isBusy = false,
  });
  final int step;
  final int totalSteps;
  final String submitLabel;
  final VoidCallback onBack;
  final VoidCallback onAdvance;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, 14 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border(top: BorderSide(color: context.borderCol)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(children: [
        if (step > 0) ...[
          Expanded(
            child: AppButton.secondary(
              label: AppStrings.back,
              onPressed: onBack,
              size: AppButtonSize.lg,
              isFullWidth: true,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: step > 0 ? 2 : 1,
          child: AppButton.primary(
            label: step < totalSteps - 1 ? AppStrings.next : submitLabel,
            onPressed: isBusy ? null : onAdvance,
            size: AppButtonSize.lg,
            isFullWidth: true,
            isLoading: isBusy,
          ),
        ),
      ]),
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
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.lock_rounded, color: AppColors.amber, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: AppText.bodySm(AppStrings.secureDataBanner,
              color: AppColors.amber),
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
      required this.imageBytes,
      required this.onTap,
      this.onClear});
  final String label;
  final IconData icon;
  final Color color;
  final Uint8List? imageBytes;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  bool get _selected => imageBytes != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 104,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: _selected ? color.withValues(alpha: 0.12) : context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(
            color: _selected ? color : context.borderCol,
            width: _selected ? 1.5 : 1,
          ),
        ),
        child: _selected
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(imageBytes!, fit: BoxFit.cover),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      color: Colors.black.withValues(alpha: 0.45),
                      child: Text(label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          )),
                    ),
                  ),
                  if (onClear != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: onClear,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppColors.textHint, size: 28),
                  const SizedBox(height: 8),
                  Text(label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 2),
                  AppText.bodyXs(AppStrings.tapToSelect, color: AppColors.textHint),
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
        AppText.labelMd('${AppStrings.certifications} (${certs.length}/10)',
            color: AppColors.textSecondary),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: AppTextField(
              controller: certCtrl,
              hint: AppStrings.certificationHint,
              prefix: const Icon(Icons.workspace_premium_rounded),
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
          AppCard(
            padding: const EdgeInsets.all(16),
            child: AppText.bodySm(
              AppStrings.noCertificationsYet,
              color: AppColors.textHint,
              textAlign: TextAlign.center,
            ),
          )
        else
          ...certs.asMap().entries.map(
                (e) => AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(children: [
                    const Icon(Icons.workspace_premium_rounded,
                        color: AppColors.amber, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child:
                          AppText.bodyMd(e.value, color: context.primaryText),
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

// ─── Profile photo field (labeled, bordered, with camera/clear badge) ─────────

class _ProfilePhotoField extends StatelessWidget {
  final Uint8List? bytes;
  final String? imageUrl;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  const _ProfilePhotoField({
    required this.bytes,
    this.imageUrl,
    required this.onTap,
    this.onClear,
  });

  bool get _has => bytes != null || (imageUrl != null && imageUrl!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    const size = 64.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Profile Photo', style: AppTypography.labelMd),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size,
                height: size,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: context.inputBg,
                  borderRadius: AppBorderRadius.lgAll,
                  border: Border.all(
                    color: _has ? AppColors.teal : context.borderCol,
                    width: _has ? 1.5 : 1,
                  ),
                ),
                child: _has
                    ? (bytes != null
                        ? Image.memory(bytes!, fit: BoxFit.cover, width: size, height: size)
                        : Image.network(imageUrl!, fit: BoxFit.cover, width: size, height: size))
                    : const Icon(Icons.camera_alt_rounded,
                        color: AppColors.textHint, size: 26),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: GestureDetector(
                  onTap: _has ? (onClear ?? onTap) : onTap,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _has ? AppColors.error : AppColors.teal,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.cardBg, width: 2),
                    ),
                    child: Icon(
                      _has ? Icons.close_rounded : Icons.camera_alt_rounded,
                      color: AppColors.textInverse,
                      size: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Picked image holder (raw bytes + base64 data URL for upload) ─────────────

class _PickedImage {
  Uint8List? bytes; // freshly picked image bytes (for preview)
  String? dataUrl; // base64 data URL to upload (only when newly picked)
  String? existingUrl; // already-uploaded remote URL (edit mode)

  bool get isSet => dataUrl != null || existingUrl != null;
}
