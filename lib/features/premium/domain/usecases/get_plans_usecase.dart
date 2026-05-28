import '../entities/plan_entity.dart';
import '../repositories/subscription_repository.dart';

class GetPlansUseCase {
  const GetPlansUseCase(this._repo);
  final SubscriptionRepository _repo;
  Future<List<PlanEntity>> call() => _repo.getPlans();
}
