import '../entities/my_subscription_entity.dart';
import '../repositories/subscription_repository.dart';

class GetMySubscriptionUseCase {
  const GetMySubscriptionUseCase(this._repo);
  final SubscriptionRepository _repo;
  Future<MySubscriptionEntity> call() => _repo.getMySubscription();
}
