import '../../domain/entities/plan_entity.dart';
import '../../domain/entities/my_subscription_entity.dart';
import '../../domain/entities/coupon_entity.dart';
import '../../domain/entities/purchase_result_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  const SubscriptionRepositoryImpl(this._ds);
  final SubscriptionRemoteDataSource _ds;

  @override
  Future<List<PlanEntity>> getPlans() => _ds.getPlans();

  @override
  Future<MySubscriptionEntity> getMySubscription() => _ds.getMySubscription();

  @override
  Future<void> selectPlan(String planId) => _ds.selectPlan(planId);

  @override
  Future<PurchaseResultEntity> purchasePlan({
    required String planId,
    required String billingCycle,
    String? couponCode,
  }) =>
      _ds.purchasePlan(planId: planId, billingCycle: billingCycle, couponCode: couponCode);

  @override
  Future<void> cancelSubscription() => _ds.cancelSubscription();

  @override
  Future<void> toggleAutoRenew(bool enabled) => _ds.toggleAutoRenew(enabled);

  @override
  Future<CouponEntity> validateCoupon({required String code, String? planId}) =>
      _ds.validateCoupon(code: code, planId: planId);

  @override
  Future<CouponEntity> applyCoupon({required String code, String? planId}) =>
      _ds.applyCoupon(code: code, planId: planId);
}
