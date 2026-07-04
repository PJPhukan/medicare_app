import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/logger.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _dobCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _bloodGroupCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _conditionsCtrl;
  late final TextEditingController _allergiesCtrl;
  String _gender = AppStrings.male;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user      = ref.read(authProvider).user;
    _nameCtrl       = TextEditingController(text: user?.name ?? '');
    _emailCtrl      = TextEditingController(text: user?.email ?? '');
    _phoneCtrl      = TextEditingController(text: user?.phone ?? '');
    _dobCtrl        = TextEditingController();
    _locationCtrl   = TextEditingController();
    _bloodGroupCtrl = TextEditingController();
    _weightCtrl     = TextEditingController();
    _heightCtrl     = TextEditingController();
    _conditionsCtrl = TextEditingController();
    _allergiesCtrl  = TextEditingController();
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _emailCtrl, _phoneCtrl, _dobCtrl, _locationCtrl,
      _bloodGroupCtrl, _weightCtrl, _heightCtrl, _conditionsCtrl, _allergiesCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    AppLogger.i('Profile update', tag: 'Profile');
    setState(() => _saving = true);
    try {
      await ref.read(updateProfileProvider).call({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'dob': _dobCtrl.text.trim(),
        'gender': _gender,
        'location': _locationCtrl.text.trim(),
        'bloodGroup': _bloodGroupCtrl.text.trim(),
        'weight': _weightCtrl.text.trim(),
        'height': _heightCtrl.text.trim(),
        'conditions': _conditionsCtrl.text.trim(),
        'allergies': _allergiesCtrl.text.trim(),
      });
      AppLogger.i('Profile updated ✓', tag: 'Profile');
      if (!mounted) return;
      AppSnackbar.success(context, AppStrings.profileUpdated);
      context.pop();
    } on Exception catch (e) {
      AppLogger.e('Profile update failed', tag: 'Profile', error: e);
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackbar.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: context.bg,
                surfaceTintColor: Colors.transparent,
                pinned: true,
                expandedHeight: 100,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.primaryText, size: 20),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: _saving ? null : _save,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _saving ? context.inputBg : AppColors.teal,
                          borderRadius: AppBorderRadius.lgAll,
                        ),
                        child: _saving
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal))
                            : const Text(AppStrings.save, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: AppColors.textInverse)),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 52, bottom: 14),
                  title: AppText.h2(AppStrings.editProfile),
                  background: Container(color: context.bg),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Avatar
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: AppColors.teal.withValues(alpha: 0.15),
                            child: const Text('AK', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.teal)),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: 30, height: 30,
                                decoration: BoxDecoration(
                                  color: AppColors.teal,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: context.bg, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: AppText.bodySm(AppStrings.changePhoto, color: AppColors.teal, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel('PERSONAL INFO'),
                    const SizedBox(height: 10),
                    _Field(label: AppStrings.fullName, controller: _nameCtrl, hint: AppStrings.fullNameHint,
                        validator: (v) => (v == null || v.trim().length < 2) ? AppStrings.nameTooShort : null),
                    const SizedBox(height: 10),
                    _Field(label: AppStrings.email, controller: _emailCtrl, hint: AppStrings.emailHint,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || !v.contains('@')) ? AppStrings.invalidEmail : null),
                    const SizedBox(height: 10),
                    _Field(label: AppStrings.phone, controller: _phoneCtrl, hint: '+91 98765 43210',
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 10),
                    _Field(label: AppStrings.dateOfBirth, controller: _dobCtrl, hint: 'DD MMM YYYY',
                        suffixIcon: Icons.calendar_today_rounded),
                    const SizedBox(height: 10),
                    // Gender picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.bodyXs(AppStrings.gender, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: context.inputBg,
                            borderRadius: AppBorderRadius.lgAll,
                            border: Border.all(color: context.borderCol),
                          ),
                          child: Row(
                            children: [AppStrings.male, AppStrings.female, AppStrings.other].map((g) {
                              final sel = _gender == g;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _gender = g),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 160),
                                    padding: const EdgeInsets.symmetric(vertical: 9),
                                    decoration: BoxDecoration(
                                      color: sel ? AppColors.teal.withValues(alpha: 0.15) : Colors.transparent,
                                      borderRadius: AppBorderRadius.mdAll,
                                      border: Border.all(color: sel ? AppColors.teal.withValues(alpha: 0.4) : Colors.transparent),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(g,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                          color: sel ? AppColors.teal : AppColors.textSecondary,
                                        )),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _Field(label: AppStrings.location, controller: _locationCtrl, hint: 'City, State',
                        suffixIcon: Icons.location_on_outlined),
                    const SizedBox(height: 24),
                    _SectionLabel('HEALTH INFO'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _Field(label: '${AppStrings.weight} (kg)', controller: _weightCtrl, hint: '70',
                            keyboardType: TextInputType.number)),
                        const SizedBox(width: 10),
                        Expanded(child: _Field(label: '${AppStrings.height} (cm)', controller: _heightCtrl, hint: '170',
                            keyboardType: TextInputType.number)),
                        const SizedBox(width: 10),
                        Expanded(child: _Field(label: AppStrings.bloodGroup, controller: _bloodGroupCtrl, hint: 'O+')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _Field(label: 'Medical Conditions', controller: _conditionsCtrl,
                        hint: 'e.g. Diabetes, Hypertension', maxLines: 2),
                    const SizedBox(height: 10),
                    _Field(label: AppStrings.knownAllergies, controller: _allergiesCtrl,
                        hint: AppStrings.allergiesHint, maxLines: 2),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: _saving ? null : _save,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: _saving ? context.inputBg : AppColors.teal,
                          borderRadius: AppBorderRadius.lgAll,
                        ),
                        alignment: Alignment.center,
                        child: _saving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal))
                            : const Text(AppStrings.save, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: AppColors.textInverse)),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textHint, letterSpacing: 1),
      );
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;
  final IconData? suffixIcon;
  final String? Function(String?)? validator;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodyXs(label, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: AppBorderRadius.lgAll,
              border: Border.all(color: context.borderCol),
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              validator: validator,
              style: TextStyle(fontSize: 14, color: context.primaryText),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                suffixIcon: suffixIcon != null
                    ? Icon(suffixIcon, size: 16, color: AppColors.textHint)
                    : null,
              ),
            ),
          ),
        ],
      );
}
