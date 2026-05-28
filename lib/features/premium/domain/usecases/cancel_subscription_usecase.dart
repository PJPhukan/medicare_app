import '../repositories/subscription_repository.dart';

class CancelSubscriptionUseCase {
  const CancelSubscriptionUseCase(this._repo);
  final SubscriptionRepository _repo;
  Future<void> call() => _repo.cancelSubscription();
}
