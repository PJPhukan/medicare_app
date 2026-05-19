import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

class InviteCaretakerScreen extends StatefulWidget {
  const InviteCaretakerScreen({super.key});

  @override
  State<InviteCaretakerScreen> createState() => _InviteCaretakerScreenState();
}

class _InviteCaretakerScreenState extends State<InviteCaretakerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  String _relationship = 'Family';
  bool _inviteByEmail = true;
  bool _sending = false;

  final _permissions = <String, bool>{
    AppStrings.permViewVitals: true,
    AppStrings.permViewMeds: true,
    AppStrings.permViewReports: false,
    AppStrings.permViewSchedule: false,
  };

  static const _relationships = ['Family', 'Spouse', 'Parent', 'Child', 'Friend', 'Professional'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendInvite() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppStrings.inviteSent, style: AppTypography.bodySm),
      backgroundColor: AppColors.teal.withValues(alpha: 0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
    ));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final hasPermission = _permissions.values.any((v) => v);

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
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 52, bottom: 14),
                  title: Text('Invite Caretaker', style: AppTypography.h2.copyWith(fontSize: 22)),
                  background: Container(color: context.bg),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Info banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.08),
                        borderRadius: AppBorderRadius.lgAll,
                        border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.teal, size: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'They\'ll receive an invite to view your health data based on permissions you set.',
                              style: AppTypography.bodyXs.copyWith(color: AppColors.teal, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel('CARETAKER DETAILS'),
                    const SizedBox(height: 10),
                    _Field(
                      label: 'Full Name',
                      controller: _nameCtrl,
                      hint: 'e.g. Priya Mehta',
                      validator: (v) => (v == null || v.trim().length < 2) ? AppStrings.nameTooShort : null,
                    ),
                    const SizedBox(height: 10),
                    // Toggle: email vs phone
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: context.inputBg,
                        borderRadius: AppBorderRadius.lgAll,
                        border: Border.all(color: context.borderCol),
                      ),
                      child: Row(
                        children: [
                          _TabChip(label: 'Email', selected: _inviteByEmail, onTap: () => setState(() => _inviteByEmail = true)),
                          _TabChip(label: 'Phone', selected: !_inviteByEmail, onTap: () => setState(() => _inviteByEmail = false)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Field(
                      label: _inviteByEmail ? AppStrings.emailAddress : AppStrings.phoneNumber,
                      controller: _contactCtrl,
                      hint: _inviteByEmail ? 'priya@email.com' : '+91 98765 43210',
                      keyboardType: _inviteByEmail ? TextInputType.emailAddress : TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return AppStrings.fieldRequired;
                        if (_inviteByEmail && !v.contains('@')) return AppStrings.invalidEmail;
                        if (!_inviteByEmail && v.trim().length < 8) return AppStrings.invalidPhone;
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel('RELATIONSHIP'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _relationships.map((r) {
                        final sel = _relationship == r;
                        return GestureDetector(
                          onTap: () => setState(() => _relationship = r),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.teal.withValues(alpha: 0.12) : context.cardBg,
                              borderRadius: AppBorderRadius.pill,
                              border: Border.all(color: sel ? AppColors.teal.withValues(alpha: 0.4) : context.borderCol),
                            ),
                            child: Text(
                              r,
                              style: AppTypography.labelSm.copyWith(
                                color: sel ? AppColors.teal : AppColors.textSecondary,
                                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel('PERMISSIONS'),
                    const SizedBox(height: 4),
                    Text('Choose what they can see', style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: AppBorderRadius.lgAll,
                        border: Border.all(color: context.borderCol),
                      ),
                      child: Column(
                        children: _permissions.entries.toList().asMap().entries.map((entry) {
                          final i = entry.key;
                          final perm = entry.value.key;
                          final val = entry.value.value;
                          final isLast = i == _permissions.length - 1;
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                child: Row(
                                  children: [
                                    Text(perm, style: AppTypography.bodySm.copyWith(color: context.primaryText)),
                                    const Spacer(),
                                    Switch(
                                      value: val,
                                      onChanged: (v) => setState(() => _permissions[perm] = v),
                                      activeThumbColor: AppColors.teal,
                                      activeTrackColor: AppColors.teal.withValues(alpha: 0.25),
                                      inactiveTrackColor: context.inputBg,
                                      inactiveThumbColor: AppColors.textHint,
                                      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast) Divider(height: 1, indent: 14, endIndent: 14, color: context.borderCol),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: (_sending || !hasPermission) ? null : _sendInvite,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: (_sending || !hasPermission) ? context.inputBg : AppColors.teal,
                          borderRadius: AppBorderRadius.lgAll,
                        ),
                        alignment: Alignment.center,
                        child: _sending
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal))
                            : Text(AppStrings.sendInvite,
                                style: AppTypography.buttonMd.copyWith(
                                  color: (_sending || !hasPermission) ? AppColors.textHint : AppColors.textInverse,
                                )),
                      ),
                    ),
                    if (!hasPermission) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text('Select at least one permission to continue',
                            style: AppTypography.bodyXs.copyWith(color: AppColors.error)),
                      ),
                    ],
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

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.teal.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: AppBorderRadius.mdAll,
              border: Border.all(color: selected ? AppColors.teal.withValues(alpha: 0.4) : Colors.transparent),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTypography.buttonSm.copyWith(
                color: selected ? AppColors.teal : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
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
              ),
            ),
          ),
        ],
      );
}
