import '../entities/plan_entity.dart';
import '../entities/my_subscription_entity.dart';
import '../entities/coupon_entity.dart';
import '../entities/purchase_result_entity.dart';

abstract class SubscriptionRepository {
  Future<List<PlanEntity>> getPlans();
  Future<MySubscriptionEntity> getMySubscription();
  Future<void> selectPlan(String planId);
  Future<PurchaseResultEntity> purchasePlan({
    required String planId,
    required String billingCycle,
    String? couponCode,
  });
  Future<void> cancelSubscription();
  Future<void> toggleAutoRenew(bool enabled);
  Future<CouponEntity> validateCoupon({required String code, String? planId});
  Future<CouponEntity> applyCoupon({required String code, String? planId});
}
