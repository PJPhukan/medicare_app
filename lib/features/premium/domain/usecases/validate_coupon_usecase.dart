import '../entities/coupon_entity.dart';
import '../repositories/subscription_repository.dart';

class ValidateCouponUseCase {
  const ValidateCouponUseCase(this._repo);
  final SubscriptionRepository _repo;

  Future<CouponEntity> call({required String code, String? planId}) =>
      _repo.validateCoupon(code: code, planId: planId);
}
