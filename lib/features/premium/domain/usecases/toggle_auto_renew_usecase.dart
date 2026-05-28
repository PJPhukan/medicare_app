import '../repositories/subscription_repository.dart';

class ToggleAutoRenewUseCase {
  const ToggleAutoRenewUseCase(this._repo);
  final SubscriptionRepository _repo;
  Future<void> call(bool enabled) => _repo.toggleAutoRenew(enabled);
}
