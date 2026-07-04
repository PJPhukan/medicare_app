import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/badges/app_badge.dart';
import '../../../../shared/widgets/texts/app_text.dart';
import '../../domain/entities/my_subscription_entity.dart';
import '../../../../core/utils/plan_feature_formatter.dart';
import 'plan_feature_row.dart';

class ActivePlanCard extends StatelessWidget {
  const ActivePlanCard({super.key, required this.subscription});

  final MySubscriptionEntity subscription;

  @override
  Widget build(BuildContext context) {
    final plan   = subscription.plan;
    final accent = AppColors.purple;
    final expiry = subscription.expiresAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.lgAll,
        border: Border.all(color: accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppBorderRadius.lgAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              color: accent.withValues(alpha: 0.10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            AppBadge(
                              label: AppStrings.planPremiumBadge,
                              variant: AppBadgeVariant.purple,
                            ),
                            AppBadge(
                              label: AppStrings.activeStatus,
                              variant: AppBadgeVariant.green,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        AppText.h3(plan.name, fontWeight: FontWeight.w800),
                        if (expiry != null) ...[
                          const SizedBox(height: 4),
                          AppText.bodyXs(
                            '${AppStrings.prescriptionExpiry} ${DateFormatter.short(expiry)}',
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.verified_rounded,
                      color: AppColors.purple, size: 28),
                ],
              ),
            ),

            // ── Features ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: plan.features
                    .map((f) => PlanFeatureRow(
                          label: formatPlanFeature(f),
                          icon: Icons.check_rounded,
                          iconColor: AppColors.green,
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
