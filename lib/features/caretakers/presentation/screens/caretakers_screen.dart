import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/skeleton/skeleton.dart';
import '../../domain/entities/caretaker_entity.dart';
import '../providers/caretakers_provider.dart';
import '../widgets/manage_caretaker_permissions_sheet.dart';
import '../../../connections/domain/entities/connection_entity.dart';
import '../../../connections/presentation/providers/connections_provider.dart';

String _fmtMonth(DateTime dt) {
  const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${m[dt.month - 1]} ${dt.year}';
}

class CaretakersScreen extends ConsumerStatefulWidget {
  const CaretakersScreen({super.key});

  @override
  ConsumerState<CaretakersScreen> createState() => _CaretakersScreenState();
}

class _CaretakersScreenState extends ConsumerState<CaretakersScreen> {
  Future<void> _inviteCaretaker() async {
    await context.push(AppRoutes.caretakerInvite);
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
    if (ok != true || !mounted) return;
    final removed = await ref.read(caretakersProvider.notifier).removeCaretaker(c.relationshipId);
    if (!mounted) return;
    if (removed) {
      AppSnackbar.success(context, AppStrings.caretakerRemoved);
    } else {
      AppSnackbar.error(context, AppStrings.somethingWentWrong);
    }
  }

  Future<void> _cancelInvite(PendingCaretakerInviteEntity invite) async {
    final ok = await AppDialog.confirm(
      context,
      title: AppStrings.cancelInvite,
      message: AppStrings.cancelInviteConfirm,
      confirmLabel: AppStrings.remove,
      cancelLabel: AppStrings.cancel,
      isDanger: true,
    );
    if (ok != true || !mounted) return;
    final cancelled = await ref.read(caretakersProvider.notifier).cancelInvite(invite.id);
    if (!mounted) return;
    if (cancelled) {
      AppSnackbar.success(context, AppStrings.inviteCancelled);
    } else {
      AppSnackbar.error(context, AppStrings.somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(caretakersProvider);
    final activeProfessionals = ref
        .watch(connectionsProvider)
        .connections
        .where((c) => c.status == 'ACTIVE')
        .toList();

    final isEmpty = st.caretakers.isEmpty &&
        st.pendingInvites.isEmpty &&
        activeProfessionals.isEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: RefreshIndicator(
          onRefresh: () => ref.read(caretakersProvider.notifier).load(),
          child: CustomScrollView(
            slivers: [
              AppSliverAppBar(
                config: AppBarConfig(
                  title: AppStrings.caretakers,
                  subtitle: 'People who help manage your health',
                  actions: [
                    AppIconButton(
                      icon: const Icon(Icons.person_add_rounded),
                      color: AppColors.teal,
                      onPressed: _inviteCaretaker,
                      tooltip: AppStrings.addCaretaker,
                    ),
                  ],
                ),
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

              if (st.isLoading && isEmpty)
                SliverToBoxAdapter(
                  child: AppListTileSkeleton.list(itemCount: 3, showTrailing: true),
                )
              else if (st.error != null && isEmpty)
                SliverFillRemaining(
                  child: AppErrorState(
                    message: st.error,
                    onRetry: () => ref.read(caretakersProvider.notifier).load(),
                  ),
                )
              else if (isEmpty)
                SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.supervisor_account_rounded,
                    title: AppStrings.noCaretakers,
                    subtitle: AppStrings.noCaretakersDesc,
                    action: _inviteCaretaker,
                    actionLabel: AppStrings.addCaretaker,
                  ),
                )
              else ...[
                // ── Family & Friends ───────────────────────────────────────────
                if (st.caretakers.isNotEmpty) ...[
                  _SectionLabel('FAMILY & FRIENDS'),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _CaretakerCard(
                          caretaker: st.caretakers[i],
                          onManagePermissions: () => showManageCaretakerPermissionsSheet(
                              context, st.caretakers[i]),
                          onRemove: () => _removeCaretaker(st.caretakers[i]),
                        ),
                        childCount: st.caretakers.length,
                      ),
                    ),
                  ),
                ],

                // ── Pending invites ─────────────────────────────────────────────
                if (st.pendingInvites.isNotEmpty) ...[
                  _SectionLabel('PENDING INVITES'),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _PendingInviteCard(
                          invite: st.pendingInvites[i],
                          onCancel: () => _cancelInvite(st.pendingInvites[i]),
                        ),
                        childCount: st.pendingInvites.length,
                      ),
                    ),
                  ),
                ],

                // ── Professionals ──────────────────────────────────────────────
                if (activeProfessionals.isNotEmpty) ...[
                  _SectionLabel('PROFESSIONALS'),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _ProfessionalCaretakerCard(conn: activeProfessionals[i]),
                        childCount: activeProfessionals.length,
                      ),
                    ),
                  ),
                ] else
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: AppText.labelXs(label, color: AppColors.textHint, fontWeight: FontWeight.w700),
        ),
      );
}

// ─── Active caretaker card ─────────────────────────────────────────────────────

class _CaretakerCard extends StatelessWidget {
  final CaretakerEntity caretaker;
  final VoidCallback onManagePermissions;
  final VoidCallback onRemove;

  const _CaretakerCard({
    required this.caretaker,
    required this.onManagePermissions,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final grantedTabs = caretaker.tabGrants.where((g) => g.hasAccess).toList();

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      borderRadius: AppBorderRadius.lgAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: caretaker.name, imageUrl: caretaker.avatarUrl, size: AppAvatarSize.md),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodyMd(caretaker.name, fontWeight: FontWeight.w700),
                    if (caretaker.contact.isNotEmpty)
                      AppText.bodyXs(caretaker.contact, color: AppColors.textSecondary),
                  ],
                ),
              ),
              AppBadge(
                label: caretaker.role == GranteeRole.family
                    ? AppStrings.roleFamily
                    : AppStrings.roleCaretaker,
                variant: AppBadgeVariant.blue,
              ),
              PopupMenuButton<String>(
                color: context.inputBg,
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textHint, size: 20),
                onSelected: (v) {
                  if (v == 'remove') onRemove();
                  if (v == 'permissions') onManagePermissions();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'permissions',
                    child: Row(
                      children: [
                        const Icon(Icons.tune_rounded, color: AppColors.teal, size: 16),
                        const SizedBox(width: 8),
                        AppText.bodySm(AppStrings.managePermissions),
                      ],
                    ),
                  ),
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
          if (grantedTabs.isEmpty)
            GestureDetector(
              onTap: onManagePermissions,
              child: AppText.bodyXs(
                'No permissions granted — tap to add',
                color: AppColors.teal,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: grantedTabs
                  .map((g) => AppBadge(label: g.tabLabel, variant: AppBadgeVariant.teal))
                  .toList(),
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

// ─── Pending invite card ───────────────────────────────────────────────────────

class _PendingInviteCard extends StatelessWidget {
  final PendingCaretakerInviteEntity invite;
  final VoidCallback onCancel;

  const _PendingInviteCard({required this.invite, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      leading: AppAvatar(name: invite.name, size: AppAvatarSize.md),
      title: invite.name,
      subtitleWidget: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (invite.contact.isNotEmpty)
              Flexible(
                child: AppText.bodyXs(invite.contact, color: AppColors.textSecondary),
              ),
            const SizedBox(width: 6),
            AppBadge(label: AppStrings.invitePending, variant: AppBadgeVariant.amber),
          ],
        ),
      ),
      trailing: AppIconButton(
        icon: const Icon(Icons.close_rounded, size: 18),
        color: AppColors.red,
        onPressed: onCancel,
        tooltip: AppStrings.cancelInvite,
      ),
    );
  }
}

// ─── Professional caretaker card ──────────────────────────────────────────────

class _ProfessionalCaretakerCard extends StatelessWidget {
  final ConnectionEntity conn;
  const _ProfessionalCaretakerCard({required this.conn});

  @override
  Widget build(BuildContext context) {
    final name = conn.professional.displayName;
    final planLabel = switch (conn.planType) {
      'HOURLY' => 'Hourly',
      'DAILY' => 'Daily',
      'MONTHLY' => 'Monthly',
      _ => conn.planType,
    };

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      borderRadius: AppBorderRadius.lgAll,
      child: Row(
        children: [
          AppContainer.tinted(
            color: AppColors.teal,
            borderRadius: AppBorderRadius.mdAll,
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.medical_services_rounded, color: AppColors.teal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyMd(name, fontWeight: FontWeight.w700),
                AppText.bodyXs('$planLabel plan · Active', color: AppColors.textSecondary),
              ],
            ),
          ),
          const AppBadge(label: 'Professional', variant: AppBadgeVariant.teal),
        ],
      ),
    );
  }
}
