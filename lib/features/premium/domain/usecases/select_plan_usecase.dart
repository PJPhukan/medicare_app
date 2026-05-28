import '../repositories/subscription_repository.dart';

class SelectPlanUseCase {
  const SelectPlanUseCase(this._repo);
  final SubscriptionRepository _repo;
  Future<void> call(String planId) => _repo.selectPlan(planId);
}
