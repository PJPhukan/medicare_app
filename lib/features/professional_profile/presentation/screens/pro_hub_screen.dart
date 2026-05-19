import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_strings.dart';
import 'become_professional_screen.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

enum _ProStatus { notApplied, pending, verified }

class _ProProfile {
  final _ProStatus status;
  final String? specialty;
  final String? license;
  final String? clinic;
  final int? experience;
  final int? activeClients;
  final double? rating;
  final String? availability;
  final String? fee;

  const _ProProfile({
    required this.status,
    this.specialty,
    this.license,
    this.clinic,
    this.experience,
    this.activeClients,
    this.rating,
    this.availability,
    this.fee,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ProHubScreen extends StatefulWidget {
  const ProHubScreen({super.key});

  @override
  State<ProHubScreen> createState() => _ProHubScreenState();
}

class _ProHubScreenState extends State<ProHubScreen> {
  // Mock: verified professional
  _ProProfile _profile = _ProProfile(
    status: _ProStatus.verified,
    specialty: 'Cardiologist',
    license: 'MCI-2019-KA-04821',
    clinic: 'Apollo Hospitals, Bengaluru',
    experience: 7,
    activeClients: 24,
    rating: 4.8,
    availability: 'Mon–Fri, 10 AM – 4 PM',
    fee: '₹500 / consultation',
  );

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
                title: Text(AppStrings.proHubTitle, style: AppTypography.h2.copyWith(fontSize: 20)),
                background: Container(color: context.bg),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_profile.status == _ProStatus.notApplied)
                    _NotAppliedView(onApply: _openApply)
                  else ...[
                    _StatusBanner(status: _profile.status),
                    const SizedBox(height: 16),
                    if (_profile.status == _ProStatus.verified) ...[
                      _StatsRow(profile: _profile),
                      const SizedBox(height: 16),
                    ],
                    _ProfileCard(
                      profile: _profile,
                      onEdit: _openEdit,
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

  void _openApply() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BecomeProfessionalScreen()),
    );
  }

  void _openEdit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BecomeProfessionalScreen(isEditing: true),
      ),
    );
  }
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
            Text(AppStrings.becomePro, style: AppTypography.h2.copyWith(fontSize: 22)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                AppStrings.proApplyDesc,
                style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
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
                      Text(item.$2, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
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
              label: Text(AppStrings.proApplyNow, style: AppTypography.buttonMd),
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
                Text(label, style: AppTypography.bodyMd.copyWith(color: color, fontWeight: FontWeight.w700)),
                Text(
                  isPending ? 'Your application is under review. We\'ll notify you within 48 hours.' : 'Your profile is live and visible to patients.',
                  style: AppTypography.bodyXs.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final _ProProfile profile;
  const _StatsRow({required this.profile});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _StatCard(label: AppStrings.proClients, value: '${profile.activeClients}', color: AppColors.teal, icon: Icons.people_rounded),
          const SizedBox(width: 10),
          _StatCard(label: AppStrings.proRating, value: '${profile.rating}★', color: AppColors.amber, icon: Icons.star_rounded),
          const SizedBox(width: 10),
          _StatCard(label: AppStrings.proExperience, value: '${profile.experience}y', color: AppColors.blue, icon: Icons.work_rounded),
        ],
      );
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: context.borderCol),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 6),
              Text(value, style: AppTypography.h3.copyWith(color: context.primaryText, fontSize: 18)),
              Text(label, style: AppTypography.bodyXs.copyWith(color: AppColors.textHint, fontSize: 10)),
            ],
          ),
        ),
      );
}

// ─── Profile card ─────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final _ProProfile profile;
  final VoidCallback onEdit;

  _ProfileCard({required this.profile, required this.onEdit});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppBorderRadius.lgAll,
          border: Border.all(color: context.borderCol),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.professionalProfile, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.1),
                        borderRadius: AppBorderRadius.pill,
                        border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit_rounded, color: AppColors.teal, size: 12),
                          const SizedBox(width: 4),
                          Text(AppStrings.edit, style: AppTypography.labelSm.copyWith(color: AppColors.teal, fontSize: 11)),
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
              (AppStrings.proAvailability, profile.availability, Icons.schedule_rounded, AppColors.green),
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
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.bodyXs.copyWith(color: AppColors.textHint)),
                Text(value, style: AppTypography.bodySm.copyWith(color: context.primaryText, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      );
}

