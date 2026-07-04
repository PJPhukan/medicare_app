import '../entities/available_coupon_entity.dart';
import '../repositories/subscription_repository.dart';

class GetAvailableCouponsUseCase {
  const GetAvailableCouponsUseCase(this._repo);
  final SubscriptionRepository _repo;

  Future<List<AvailableCouponEntity>> call() => _repo.getAvailableCoupons();
}
