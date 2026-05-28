import '../entities/purchase_result_entity.dart';
import '../repositories/subscription_repository.dart';

class PurchasePlanUseCase {
  const PurchasePlanUseCase(this._repo);
  final SubscriptionRepository _repo;

  Future<PurchaseResultEntity> call({
    required String planId,
    required String billingCycle,
    String? couponCode,
  }) =>
      _repo.purchasePlan(
        planId: planId,
        billingCycle: billingCycle,
        couponCode: couponCode,
      );
}
