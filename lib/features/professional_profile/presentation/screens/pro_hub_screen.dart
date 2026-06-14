import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/skeleton/skeleton_base.dart';
import '../providers/pro_profile_provider.dart';
import 'become_professional_screen.dart';
import 'service_areas_screen.dart';
import 'payout_details_screen.dart';
import '../../../../core/network/connectivity_monitor.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

enum _ProStatus { notApplied, pending, verified }

class _ProProfile {
  final _ProStatus status;
  final String? specialty;
  final String? license;
  final String? clinic;
  final int? experience;
  final String? fee;

  const _ProProfile({
    required this.status,
    this.specialty,
    this.license,
    this.clinic,
    this.experience,
    this.fee,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ProHubScreen extends ConsumerWidget {
  const ProHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isOnlineProvider)) {
      return const OfflinePage(featureName: 'Professional Hub');
    }
    final state = ref.watch(proProfileProvider);

    _ProProfile profile;
    if (state.isLoading && state.profile == null) {
      profile = const _ProProfile(status: _ProStatus.pending);
    } else if (state.notFound) {
      profile = const _ProProfile(status: _ProStatus.notApplied);
    } else if (state.profile != null) {
      final e = state.profile!;
      final currency = e.currency ?? '₹';
      final fee = e.basePrice != null ? '$currency${e.basePrice!.toStringAsFixed(0)} / consultation' : null;
      profile = _ProProfile(
        status: e.isVerified ? _ProStatus.verified : _ProStatus.pending,
        specialty: e.categoryLabel,
        license: e.certifications.isNotEmpty ? e.certifications.first : null,
        clinic: e.address,
        experience: e.experienceYrs,
        fee: fee,
      );
    } else {
      profile = const _ProProfile(status: _ProStatus.notApplied);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.overlayStyle,
      child: Scaffold(
        backgroundColor: context.bg,
        body: RefreshIndicator(
          color: AppColors.teal,
          onRefresh: () => ref.read(proProfileProvider.notifier).load(),
          child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: context.bg,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              expandedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
                title: const Text(AppStrings.proHubTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                background: Container(color: context.bg),
              ),
            ),
            if (state.isLoading && state.profile == null)
              const SliverFillRemaining(child: _LoadingSkeleton())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (profile.status == _ProStatus.notApplied)
                      _NotAppliedView(onApply: () => _openApply(context))
                    else ...[
                      _StatusBanner(status: profile.status),
                      const SizedBox(height: 16),
                      _ProfileCard(profile: profile, onEdit: () => _openEdit(context)),
                      const SizedBox(height: 12),
                      _ServiceAreasCard(onTap: () => _openServiceAreas(context)),
                      const SizedBox(height: 12),
                      _PayoutDetailsCard(onTap: () => _openPayoutDetails(context)),
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

  void _openApply(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const BecomeProfessionalScreen()),
      );

  void _openEdit(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const BecomeProfessionalScreen(isEditing: true)),
      );

  void _openServiceAreas(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ServiceAreasScreen()),
      );

  void _openPayoutDetails(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PayoutDetailsScreen()),
      );
}

// ─── Payout details card ──────────────────────────────────────────────────────

class _PayoutDetailsCard extends StatelessWidget {
  final VoidCallback onTap;
  const _PayoutDetailsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          children: [
            AppContainer.tinted(
              color: AppColors.green,
              borderRadius: AppBorderRadius.mdAll,
              padding: const EdgeInsets.all(11),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  size: 20, color: AppColors.green),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.labelMd('Payout Details', color: context.primaryText),
                  const SizedBox(height: 2),
                  AppText.bodyXs(
                    'Add the bank account or UPI where you get paid',
                    color: context.secondaryText,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

// ─── Service areas card ───────────────────────────────────────────────────────

class _ServiceAreasCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ServiceAreasCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          children: [
            AppContainer.tinted(
              color: AppColors.teal,
              borderRadius: AppBorderRadius.mdAll,
              padding: const EdgeInsets.all(11),
              child: const Icon(Icons.map_rounded, size: 20, color: AppColors.teal),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.labelMd('Manage Service Areas', color: context.primaryText),
                  const SizedBox(height: 2),
                  AppText.bodyXs(
                    'Choose the localities where patients can find you',
                    color: context.secondaryText,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

// ─── Loading skeleton ─────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) => AppSkeleton(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: double.infinity, height: 64, borderRadius: BorderRadius.circular(12)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: SkeletonBox(height: 80, borderRadius: BorderRadius.circular(12))),
                const SizedBox(width: 10),
                Expanded(child: SkeletonBox(height: 80, borderRadius: BorderRadius.circular(12))),
                const SizedBox(width: 10),
                Expanded(child: SkeletonBox(height: 80, borderRadius: BorderRadius.circular(12))),
              ]),
              const SizedBox(height: 16),
              SkeletonBox(width: double.infinity, height: 240, borderRadius: BorderRadius.circular(12)),
            ],
          ),
        ),
      );
}

// ─── Not applied view ─────────────────────────────────────────────────────────

class _NotAppliedView extends StatelessWidget {
  final VoidCallback onApply;
  const _NotAppliedView({required this.onApply});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40),
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.badge_rounded, color: AppColors.purple, size: 40),
            ),
            const SizedBox(height: 24),
            AppText.h2(AppStrings.becomePro),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: AppText.bodySm(
                AppStrings.proApplyDesc,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ...[
              (Icons.verified_user_rounded, 'Get verified badge', AppColors.teal),
              (Icons.people_rounded, 'Accept patient connections', AppColors.blue),
              (Icons.monetization_on_rounded, 'Set your consultation fee', AppColors.amber),
            ].map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.$1, color: item.$3, size: 18),
                      const SizedBox(width: 10),
                      AppText.bodySm(item.$2, color: AppColors.textSecondary),
                    ],
                  ),
                )),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onApply,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text(AppStrings.proApplyNow, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
            ),
          ],
        ),
      );
}

// ─── Status banner ────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final _ProStatus status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPending = status == _ProStatus.pending;
    final color = isPending ? AppColors.amber : AppColors.teal;
    final icon = isPending ? Icons.hourglass_top_rounded : Icons.verified_rounded;
    final label = isPending ? AppStrings.proPending : AppStrings.proVerified;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyMd(label, color: color, fontWeight: FontWeight.w700),
                AppText.bodyXs(
                  isPending
                      ? 'Your application is under review. We\'ll notify you within 48 hours.'
                      : 'Your profile is live and visible to patients.',
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile card ─────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final _ProProfile profile;
  final VoidCallback onEdit;

  const _ProfileCard({required this.profile, required this.onEdit});

  @override
  Widget build(BuildContext context) => AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.bodyMd(AppStrings.professionalProfile, fontWeight: FontWeight.w700),
                  GestureDetector(
                    onTap: onEdit,
                    child: AppContainer.tinted(
                      color: AppColors.teal,
                      borderRadius: AppBorderRadius.pill,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit_rounded, color: AppColors.teal, size: 12),
                          const SizedBox(width: 4),
                          const Text(AppStrings.edit, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.teal)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: context.borderCol, height: 1),
            ...[
              (AppStrings.proSpecialty, profile.specialty, Icons.local_hospital_rounded, AppColors.teal),
              (AppStrings.proLicense, profile.license, Icons.badge_rounded, AppColors.blue),
              (AppStrings.proClinic, profile.clinic, Icons.business_rounded, AppColors.purple),
              (AppStrings.proExperience, profile.experience != null ? '${profile.experience} yrs' : null, Icons.work_rounded, AppColors.green),
              (AppStrings.proConsultationFee, profile.fee, Icons.payments_rounded, AppColors.amber),
            ].map((row) => _DetailRow(label: row.$1, value: row.$2 ?? '—', icon: row.$3, color: row.$4)),
          ],
        ),
      );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DetailRow({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyXs(label, color: AppColors.textHint),
                AppText.bodySm(value, color: context.primaryText, fontWeight: FontWeight.w600),
              ],
            ),
          ],
        ),
      );
}
