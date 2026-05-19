import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class _Caretaker {
  final String id;
  final String name;
  final String relationship;
  final String since;
  final Color avatarColor;
  final List<String> permissions;

  const _Caretaker({
    required this.id,
    required this.name,
    required this.relationship,
    required this.since,
    required this.avatarColor,
    required this.permissions,
  });
}

// ─── Mock data ────────────────────────────────────────────────────────────────

final _kCaretakers = [
  _Caretaker(
    id: 'c1',
    name: 'Priya Mehta',
    relationship: 'Spouse',
    since: 'Feb 2026',
    avatarColor: AppColors.pink,
    permissions: [AppStrings.permViewVitals, AppStrings.permViewMeds, AppStrings.permViewSchedule],
  ),
  _Caretaker(
    id: 'c2',
    name: 'Rahul Mehta',
    relationship: 'Son',
    since: 'Mar 2026',
    avatarColor: AppColors.blue,
    permissions: [AppStrings.permViewVitals, AppStrings.permViewReports],
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class CaretakersScreen extends StatefulWidget {
  const CaretakersScreen({super.key});

  @override
  State<CaretakersScreen> createState() => _CaretakersScreenState();
}

class _CaretakersScreenState extends State<CaretakersScreen> {
  final List<_Caretaker> _caretakers = List.from(_kCaretakers);

  Future<void> _inviteCaretaker() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InviteSheet(
        onInvite: (name, rel) {
          setState(() => _caretakers.add(
                _Caretaker(
                  id: 'c_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  relationship: rel,
                  since: 'Today',
                  avatarColor: AppColors.green,
                  permissions: [AppStrings.permViewVitals],
                ),
              ));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppStrings.inviteSent, style: AppTypography.bodySm)),
            );
          }
        },
      ),
    );
  }

  void _removeCaretaker(_Caretaker c) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardBg,
        title: Text(AppStrings.removeCaretaker, style: AppTypography.h3),
        content: Text(AppStrings.removeCaretakerConfirm, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.cancel, style: AppTypography.bodySm)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.remove, style: AppTypography.bodySm.copyWith(color: AppColors.red)),
          ),
        ],
      ),
    ).then((ok) {
      if (ok == true && mounted) {
        setState(() => _caretakers.remove(c));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.caretakerRemoved, style: AppTypography.bodySm)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
                title: Text(AppStrings.caretakers, style: AppTypography.h2.copyWith(fontSize: 22)),
                background: Container(color: context.bg),
              ),
              actions: [
                IconButton(
                  onPressed: _inviteCaretaker,
                  icon: const Icon(Icons.person_add_rounded, color: AppColors.teal),
                  tooltip: AppStrings.addCaretaker,
                ),
                const SizedBox(width: 8),
              ],
            ),
            // Info banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.08),
                    borderRadius: AppBorderRadius.mdAll,
                    border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.blue, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Caretakers can view your health data based on the permissions you grant them.',
                          style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_caretakers.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.supervisor_account_rounded, size: 36, color: AppColors.blue),
                      ),
                      const SizedBox(height: 20),
                      Text(AppStrings.noCaretakers, style: AppTypography.h3.copyWith(fontSize: 17)),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          AppStrings.noCaretakersDesc,
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _inviteCaretaker,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          foregroundColor: context.bg,
                          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        icon: const Icon(Icons.person_add_rounded, size: 18),
                        label: Text(AppStrings.addCaretaker, style: AppTypography.buttonMd),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _CaretakerCard(
                      caretaker: _caretakers[i],
                      onRemove: () => _removeCaretaker(_caretakers[i]),
                    ),
                    childCount: _caretakers.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _CaretakerCard extends StatelessWidget {
  final _Caretaker caretaker;
  final VoidCallback onRemove;

  _CaretakerCard({required this.caretaker, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: context.borderCol),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: caretaker.avatarColor.withValues(alpha: 0.15),
                  child: Text(
                    caretaker.name[0],
                    style: AppTypography.h3.copyWith(color: caretaker.avatarColor, fontSize: 18),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caretaker.name,
                        style: AppTypography.bodyMd.copyWith(color: context.primaryText, fontWeight: FontWeight.w700),
                      ),
                      Text(caretaker.relationship, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  color: context.inputBg,
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.textHint, size: 20),
                  onSelected: (v) { if (v == 'remove') onRemove(); },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          const Icon(Icons.person_remove_rounded, color: AppColors.red, size: 16),
                          const SizedBox(width: 8),
                          Text(AppStrings.removeCaretaker, style: AppTypography.bodySm.copyWith(color: AppColors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: context.borderCol, height: 1),
            const SizedBox(height: 10),
            Text(
              AppStrings.permissionsLabel,
              style: AppTypography.bodyXs.copyWith(color: AppColors.textHint, fontWeight: FontWeight.w600, letterSpacing: 0.6),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: caretaker.permissions.map((p) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.1),
                      borderRadius: AppBorderRadius.pill,
                      border: Border.all(color: AppColors.teal.withValues(alpha: 0.25)),
                    ),
                    child: Text(p, style: AppTypography.bodyXs.copyWith(color: AppColors.teal, fontSize: 10, fontWeight: FontWeight.w600)),
                  )).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppStrings.caretakerSince} ${caretaker.since}',
              style: AppTypography.bodyXs.copyWith(color: AppColors.textHint, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Invite sheet ─────────────────────────────────────────────────────────────

class _InviteSheet extends StatefulWidget {
  final void Function(String name, String relationship) onInvite;
  const _InviteSheet({required this.onInvite});

  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  final _emailCtrl = TextEditingController();
  final _relCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _relCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final email = _emailCtrl.text.trim();
    final rel = _relCtrl.text.trim();
    if (email.isEmpty) return;
    Navigator.pop(context);
    widget.onInvite(email.split('@').first, rel.isEmpty ? 'Contact' : rel);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPad = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardPad),
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 20),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: context.borderCol, borderRadius: AppBorderRadius.pill),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.addCaretaker, style: AppTypography.h3.copyWith(fontSize: 17)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded, color: AppColors.textHint, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _FieldLabel(AppStrings.emailAddress, required: true),
            const SizedBox(height: 6),
            _InviteField(controller: _emailCtrl, hint: AppStrings.emailHint, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _FieldLabel(AppStrings.relationship),
            const SizedBox(height: 6),
            _InviteField(controller: _relCtrl, hint: 'e.g. Spouse, Parent, Son'),
            const SizedBox(height: 24),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _emailCtrl,
              builder: (_, val, __) {
                final canSend = val.text.trim().isNotEmpty;
                return SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: canSend ? _send : null,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: canSend ? AppColors.teal : context.inputBg,
                        borderRadius: AppBorderRadius.lgAll,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.send_rounded, size: 16, color: canSend ? context.bg : AppColors.textHint),
                          SizedBox(width: 8),
                          Text(
                            AppStrings.sendInvite,
                            style: AppTypography.buttonMd.copyWith(color: canSend ? context.bg : AppColors.textHint),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  _FieldLabel(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(text, style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          if (required) ...[const SizedBox(width: 3), const Text('*', style: TextStyle(color: AppColors.red, fontSize: 12))],
        ],
      );
}

class _InviteField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  _InviteField({required this.controller, required this.hint, this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: context.inputBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTypography.bodyMd.copyWith(color: context.primaryText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      );
}
