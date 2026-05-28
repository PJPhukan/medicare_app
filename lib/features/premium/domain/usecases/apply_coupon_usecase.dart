import '../entities/coupon_entity.dart';
import '../repositories/subscription_repository.dart';

class ApplyCouponUseCase {
  const ApplyCouponUseCase(this._repo);
  final SubscriptionRepository _repo;

  Future<CouponEntity> call({required String code, String? planId}) =>
      _repo.applyCoupon(code: code, planId: planId);
}
