import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/plan_feature_formatter.dart';
import '../../../../core/utils/pricing_utils.dart';
import '../../../../shared/widgets/badges/app_badge.dart';
import '../../../../shared/widgets/texts/app_text.dart';
import '../../domain/entities/plan_entity.dart';
import 'plan_feature_row.dart';

export '../../../../core/utils/plan_feature_formatter.dart' show formatPlanFeature;

enum BillingCycle { monthly, yearly }

const _kAnim = Duration(milliseconds: 200);

const _currencySymbols = <String, String>{
  'INR': '₹',
  'USD': '\$',
  'EUR': '€',
  'GBP': '£',
  'JPY': '¥',
  'AED': 'د.إ',
};

class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.cycle,
    required this.selected,
    required this.onTap,
    this.lowerPlan,
  });

  final PlanEntity plan;
  final BillingCycle cycle;
  final bool selected;
  final VoidCallback onTap;

  /// The next-cheaper plan whose features this plan inherits.
  final PlanEntity? lowerPlan;

  Color get _accent => plan.isFree ? AppColors.teal : AppColors.purple;

  String get _price {
    if (plan.isFree) return AppStrings.planFreePrice;
    final sym = _currencySymbols[plan.currency] ?? plan.currency;
    if (cycle == BillingCycle.yearly && plan.priceYearly > 0) {
      return '$sym${plan.priceYearly.toStringAsFixed(0)}';
    }
    return '$sym${plan.priceMonthly.toStringAsFixed(0)}';
  }

  String get _period {
    if (plan.isFree) return '';
    return cycle == BillingCycle.yearly
        ? AppStrings.planPeriodYear
        : AppStrings.planPeriodMonth;
  }

  int get _yearlySavings => PricingUtils.yearlySavingsPct(plan);

  Iterable<Widget> _buildFeatures() {
    final inherited = lowerPlan?.features.toSet() ?? {};
    return plan.features
        .where((f) => !inherited.contains(f))
        .map((f) => PlanFeatureRow(
              label: formatPlanFeature(f),
              icon: Icons.check_rounded,
              iconColor: _accent,
            ));
  }

  @override
  Widget build(BuildContext context) {
    final cardBg      = context.isDark ? AppColors.dark800 : AppColors.white;
    final borderColor = selected ? _accent : context.borderCol;
    final showSavings = cycle == BillingCycle.yearly && _yearlySavings > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.lgAll,
        child: AnimatedContainer(
          duration: _kAnim,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: AppBorderRadius.lgAll,
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
            boxShadow: selected
                ? AppShadows.softCardRaised(context.isDark, color: _accent)
                : AppShadows.softCard(context.isDark),
          ),
          child: ClipRRect(
            borderRadius: AppBorderRadius.lgAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────
                AnimatedContainer(
                  duration: _kAnim,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  color: _accent.withValues(alpha: selected ? 0.10 : 0.05),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                AppText.labelLg(
                                  plan.name,
                                  fontWeight: FontWeight.w700,
                                  color: _accent,
                                ),
                                if (plan.trialDays > 0)
                                  AppBadge(
                                    label: '${plan.trialDays}${AppStrings.planDayTrial}',
                                    variant: AppBadgeVariant.amber,
                                  ),
                                if (showSavings)
                                  AppBadge(
                                    label: '${AppStrings.planSave} $_yearlySavings%',
                                    variant: AppBadgeVariant.green,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                AppText.h2(
                                  _price,
                                  color: _accent,
                                  fontWeight: FontWeight.w800,
                                ),
                                if (_period.isNotEmpty) ...[
                                  const SizedBox(width: 2),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: AppText.bodyXs(
                                      _period,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ── Selector circle ────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: AnimatedContainer(
                          duration: _kAnim,
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? _accent : context.borderCol,
                              width: 2,
                            ),
                            color: selected ? _accent : Colors.transparent,
                          ),
                          child: selected
                              ? const Icon(Icons.check_rounded,
                                  size: 13, color: Colors.white)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Features body ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (plan.description.isNotEmpty) ...[
                        AppText.bodySm(
                          plan.description,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 10),
                      ],

                      if (lowerPlan != null) ...[
                        PlanFeatureRow(
                          label: '${AppStrings.planEverythingIn} ${lowerPlan!.name}',
                          icon: Icons.layers_rounded,
                          iconColor: _accent,
                          bold: true,
                        ),
                        const SizedBox(height: 2),
                      ],

                      ..._buildFeatures(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
