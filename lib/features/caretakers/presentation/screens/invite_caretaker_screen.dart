import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../core/utils/logger.dart';
import '../providers/caretakers_provider.dart';

class InviteCaretakerScreen extends ConsumerStatefulWidget {
  const InviteCaretakerScreen({super.key});

  @override
  ConsumerState<InviteCaretakerScreen> createState() => _InviteCaretakerScreenState();
}

class _InviteCaretakerScreenState extends ConsumerState<InviteCaretakerScreen> {
  final _nameCtrl    = TextEditingController();
  final _contactCtrl = TextEditingController();
  String _relationship = 'Family';
  bool _inviteByEmail = true;
  bool _sending = false;
  String? _nameError;
  String? _contactError;

  final _permissions = <String, bool>{
    AppStrings.permViewVitals:   true,
    AppStrings.permViewMeds:     true,
    AppStrings.permViewReports:  false,
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
    final name    = _nameCtrl.text.trim();
    final contact = _contactCtrl.text.trim();
    String? nameErr    = name.length < 2 ? AppStrings.nameTooShort : null;
    String? contactErr;
    if (contact.isEmpty) {
      contactErr = AppStrings.fieldRequired;
    } else if (_inviteByEmail && !contact.contains('@')) {
      contactErr = AppStrings.invalidEmail;
    } else if (!_inviteByEmail && contact.length < 8) {
      contactErr = AppStrings.invalidPhone;
    }
    if (nameErr != null || contactErr != null) {
      setState(() { _nameError = nameErr; _contactError = contactErr; });
      return;
    }
    AppLogger.i('Caretaker invite → rel:$_relationship', tag: 'Caretakers');
    setState(() => _sending = true);
    try {
      await ref.read(inviteCaretakerProvider).call(
        phone: contact,
        relationshipId: _relationship,
        permissions: _permissions.entries.where((e) => e.value).map((e) => e.key).toList(),
      );
      AppLogger.i('Caretaker invite sent ✓', tag: 'Caretakers');
      if (!mounted) return;
      AppSnackbar.success(context, AppStrings.inviteSent);
      context.pop(true);
    } on Exception catch (e) {
      AppLogger.e('Caretaker invite failed', tag: 'Caretakers', error: e);
      if (!mounted) return;
      setState(() => _sending = false);
      AppSnackbar.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPermission = _permissions.values.any((v) => v);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              expandedHeight: 100,
              leading: AppIconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.primaryText, size: 20),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 52, bottom: 14),
                title: AppText.h2('Invite Caretaker'),
                background: Container(color: context.bg),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Info banner
                  AppContainer.tinted(
                    color: AppColors.teal,
                    borderRadius: AppBorderRadius.lgAll,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.teal, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppText.bodyXs(
                            'They\'ll receive an invite to view your health data based on permissions you set.',
                            color: AppColors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  AppText.labelXs('CARETAKER DETAILS', color: AppColors.textHint, fontWeight: FontWeight.w600),
                  const SizedBox(height: 10),

                  AppTextField(
                    controller: _nameCtrl,
                    label: 'Full Name',
                    hint: 'e.g. Priya Mehta',
                    errorText: _nameError,
                    onChanged: (_) => setState(() => _nameError = null),
                  ),
                  const SizedBox(height: 10),

                  // Email / Phone toggle
                  AppContainer(
                    color: context.inputBg,
                    borderRadius: AppBorderRadius.lgAll,
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _TabChip(
                          label: 'Email',
                          selected: _inviteByEmail,
                          onTap: () => setState(() { _inviteByEmail = true; _contactError = null; }),
                        ),
                        _TabChip(
                          label: 'Phone',
                          selected: !_inviteByEmail,
                          onTap: () => setState(() { _inviteByEmail = false; _contactError = null; }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  AppTextField(
                    controller: _contactCtrl,
                    label: _inviteByEmail ? AppStrings.emailAddress : AppStrings.phoneNumber,
                    hint: _inviteByEmail ? 'priya@email.com' : '+91 98765 43210',
                    keyboardType: _inviteByEmail ? TextInputType.emailAddress : TextInputType.phone,
                    errorText: _contactError,
                    onChanged: (_) => setState(() => _contactError = null),
                  ),
                  const SizedBox(height: 24),

                  AppText.labelXs('RELATIONSHIP', color: AppColors.textHint, fontWeight: FontWeight.w600),
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
                            border: Border.all(
                              color: sel ? AppColors.teal.withValues(alpha: 0.4) : context.borderCol,
                            ),
                          ),
                          child: AppText.labelSm(
                            r,
                            color: sel ? AppColors.teal : AppColors.textSecondary,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  AppText.labelXs('PERMISSIONS', color: AppColors.textHint, fontWeight: FontWeight.w600),
                  const SizedBox(height: 4),
                  AppText.bodyXs('Choose what they can see', color: AppColors.textSecondary),
                  const SizedBox(height: 10),

                  AppCard(
                    padding: EdgeInsets.zero,
                    borderRadius: AppBorderRadius.lgAll,
                    child: Column(
                      children: _permissions.entries.toList().asMap().entries.map((entry) {
                        final i    = entry.key;
                        final perm = entry.value.key;
                        final val  = entry.value.value;
                        final isLast = i == _permissions.length - 1;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              child: Row(
                                children: [
                                  AppText.bodySm(perm),
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
                            if (!isLast)
                              Divider(height: 1, indent: 14, endIndent: 14, color: context.borderCol),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  AppButton(
                    label: AppStrings.sendInvite,
                    isFullWidth: true,
                    isLoading: _sending,
                    variant: AppButtonVariant.primary,
                    onPressed: (!_sending && hasPermission) ? _sendInvite : null,
                  ),

                  if (!hasPermission) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: AppText.bodyXs(
                        'Select at least one permission to continue',
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab chip (email/phone toggle) ────────────────────────────────────────────

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
              border: Border.all(
                color: selected ? AppColors.teal.withValues(alpha: 0.4) : Colors.transparent,
              ),
            ),
            alignment: Alignment.center,
            child: AppText.labelSm(
              label,
              color: selected ? AppColors.teal : AppColors.textSecondary,
            ),
          ),
        ),
      );
}
