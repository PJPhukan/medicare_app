import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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
    _nameCtrl       = TextEditingController(text: 'Arjun Kumar');
    _emailCtrl      = TextEditingController(text: 'arjun@email.com');
    _phoneCtrl      = TextEditingController(text: '+91 98765 43210');
    _dobCtrl        = TextEditingController(text: '15 Mar 1990');
    _locationCtrl   = TextEditingController(text: 'Mumbai, Maharashtra');
    _bloodGroupCtrl = TextEditingController(text: 'O+');
    _weightCtrl     = TextEditingController(text: '72');
    _heightCtrl     = TextEditingController(text: '175');
    _conditionsCtrl = TextEditingController(text: 'Type 2 Diabetes');
    _allergiesCtrl  = TextEditingController(text: 'Penicillin');
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
    setState(() => _saving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppStrings.profileUpdated, style: AppTypography.bodySm),
      backgroundColor: AppColors.teal.withValues(alpha: 0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
    ));
    Navigator.pop(context);
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
                  onPressed: () => Navigator.pop(context),
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
                            : Text(AppStrings.save, style: AppTypography.buttonSm.copyWith(color: AppColors.textInverse)),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 52, bottom: 14),
                  title: Text(AppStrings.editProfile, style: AppTypography.h2.copyWith(fontSize: 22)),
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
                            child: Text('AK', style: AppTypography.h1.copyWith(color: AppColors.teal, fontSize: 28)),
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
                      child: Text(AppStrings.changePhoto, style: AppTypography.bodySm.copyWith(color: AppColors.teal, fontWeight: FontWeight.w600)),
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
                        Text(AppStrings.gender,
                            style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
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
                                        style: AppTypography.buttonSm.copyWith(
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
                            : Text(AppStrings.save, style: AppTypography.buttonMd.copyWith(color: AppColors.textInverse)),
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
        style: AppTypography.labelXs.copyWith(color: AppColors.textHint, letterSpacing: 1),
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
          Text(label, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
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
              style: AppTypography.bodyMd.copyWith(color: context.primaryText),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
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
