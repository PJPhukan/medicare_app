import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/caretaker_entity.dart';
import '../providers/caretakers_provider.dart';
import 'invite_caretaker_screen.dart';

String _fmtMonth(String iso) {
  try {
    final dt = DateTime.parse(iso);
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[dt.month - 1]} ${dt.year}';
  } catch (_) { return iso; }
}

class CaretakersScreen extends ConsumerStatefulWidget {
  const CaretakersScreen({super.key});

  @override
  ConsumerState<CaretakersScreen> createState() => _CaretakersScreenState();
}

class _CaretakersScreenState extends ConsumerState<CaretakersScreen> {
  Future<void> _inviteCaretaker() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const InviteCaretakerScreen()));
    if (mounted) ref.read(caretakersProvider.notifier).load();
  }

  Future<void> _removeCaretaker(CaretakerEntity c) async {
    final ok = await AppDialog.confirm(
      context,
      title: AppStrings.removeCaretaker,
      message: AppStrings.removeCaretakerConfirm,
      confirmLabel: AppStrings.remove,
      cancelLabel: AppStrings.cancel,
      isDanger: true,
    );
    if (ok == true && mounted) {
      await ref.read(caretakersProvider.notifier).removeCaretaker(c.id);
      if (!mounted) return;
      AppSnackbar.success(context, AppStrings.caretakerRemoved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(caretakersProvider);
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
                title: AppText.h2(AppStrings.caretakers),
                background: Container(color: context.bg),
              ),
              actions: [
                AppIconButton(
                  icon: const Icon(Icons.person_add_rounded),
                  color: AppColors.teal,
                  onPressed: _inviteCaretaker,
                  tooltip: AppStrings.addCaretaker,
                ),
                const SizedBox(width: 8),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: AppContainer.tinted(
                  color: AppColors.blue,
                  borderRadius: AppBorderRadius.mdAll,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.blue, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppText.bodyXs(
                          'Caretakers can view your health data based on the permissions you grant them.',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (st.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2)),
              )
            else if (st.error != null && st.caretakers.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText.bodySm(st.error!, color: AppColors.error),
                      const SizedBox(height: 12),
                      AppButton.ghost(
                        label: 'Retry',
                        color: AppColors.teal,
                        onPressed: () => ref.read(caretakersProvider.notifier).load(),
                      ),
                    ],
                  ),
                ),
              )
            else if (st.caretakers.isEmpty)
              SliverFillRemaining(
                child: AppEmptyState(
                  icon: Icons.supervisor_account_rounded,
                  title: AppStrings.noCaretakers,
                  subtitle: AppStrings.noCaretakersDesc,
                  action: _inviteCaretaker,
                  actionLabel: AppStrings.addCaretaker,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _CaretakerCard(
                      caretaker: st.caretakers[i],
                      onRemove: () => _removeCaretaker(st.caretakers[i]),
                    ),
                    childCount: st.caretakers.length,
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
  final CaretakerEntity caretaker;
  final VoidCallback onRemove;

  const _CaretakerCard({required this.caretaker, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final name = caretaker.caretakerUser.name;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      borderRadius: AppBorderRadius.lgAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: name, size: AppAvatarSize.md),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodyMd(name, fontWeight: FontWeight.w700),
                    AppText.bodyXs(caretaker.relationship.label, color: AppColors.textSecondary),
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
                        AppText.bodySm(AppStrings.removeCaretaker, color: AppColors.red),
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
          AppText.bodyXs(
            AppStrings.permissionsLabel,
            color: AppColors.textHint,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: caretaker.permissions.map((p) => AppContainer.tinted(
              color: AppColors.teal,
              borderRadius: AppBorderRadius.pill,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: AppText.bodyXs(p, color: AppColors.teal, fontWeight: FontWeight.w600),
            )).toList(),
          ),
          const SizedBox(height: 8),
          AppText.bodyXs(
            '${AppStrings.caretakerSince} ${_fmtMonth(caretaker.createdAt)}',
            color: AppColors.textHint,
          ),
        ],
      ),
    );
  }
}
