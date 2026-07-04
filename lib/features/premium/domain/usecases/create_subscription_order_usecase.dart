import '../entities/subscription_order_entity.dart';
import '../repositories/subscription_repository.dart';

class CreateSubscriptionOrderUseCase {
  const CreateSubscriptionOrderUseCase(this._repo);
  final SubscriptionRepository _repo;

  Future<SubscriptionOrderEntity> call({
    required String planId,
    required String billingCycle,
    String? couponCode,
  }) =>
      _repo.createOrder(planId: planId, billingCycle: billingCycle, couponCode: couponCode);
}
