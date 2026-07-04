import '../../features/premium/domain/entities/plan_entity.dart';

abstract final class PricingUtils {
  /// Yearly savings as a percentage (0–100) vs paying monthly for 12 months.
  /// Returns 0 for free plans or when price data is missing/inconsistent.
  static int yearlySavingsPct(PlanEntity plan) {
    if (plan.isFree || plan.priceMonthly == 0 || plan.priceYearly == 0) return 0;
    final monthly12 = plan.priceMonthly * 12;
    return ((monthly12 - plan.priceYearly) / monthly12 * 100)
        .round()
        .clamp(0, 100);
  }

  /// Max yearly savings % across all plans in a list.
  static int maxYearlySavingsPct(List<PlanEntity> plans) =>
      plans.fold(0, (best, p) => yearlySavingsPct(p) > best ? yearlySavingsPct(p) : best);
}
