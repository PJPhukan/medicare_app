import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/pricing_utils.dart';
import '../../../../shared/widgets/texts/app_text.dart';
import '../../domain/entities/plan_entity.dart';
import 'plan_card.dart' show BillingCycle;

const _kAnim = Duration(milliseconds: 200);

class SubscriptionBillingToggle extends StatelessWidget {
  const SubscriptionBillingToggle({
    super.key,
    required this.cycle,
    required this.plans,
    required this.onChanged,
  });

  final BillingCycle cycle;
  final List<PlanEntity> plans;
  final ValueChanged<BillingCycle> onChanged;

  @override
  Widget build(BuildContext context) {
    final savings = PricingUtils.maxYearlySavingsPct(plans);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: context.inputBg,
          borderRadius: AppBorderRadius.pill,
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Tab(
              label: AppStrings.monthly,
              active: cycle == BillingCycle.monthly,
              onTap: () => onChanged(BillingCycle.monthly),
            ),
            _Tab(
              label: AppStrings.planBillingYearly,
              active: cycle == BillingCycle.yearly,
              onTap: () => onChanged(BillingCycle.yearly),
              badge: savings > 0 ? '${AppStrings.planSave} $savings%' : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.active,
    required this.onTap,
    this.badge,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.pill,
        child: AnimatedContainer(
          duration: _kAnim,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.teal : Colors.transparent,
            borderRadius: AppBorderRadius.pill,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.labelMd(
                label,
                color: active ? Colors.white : AppColors.textSecondary,
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white.withValues(alpha: 0.25)
                        : AppColors.green.withValues(alpha: 0.15),
                    borderRadius: AppBorderRadius.pill,
                  ),
                  child: AppText.labelXs(
                    badge!,
                    color: active ? Colors.white : AppColors.green,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
