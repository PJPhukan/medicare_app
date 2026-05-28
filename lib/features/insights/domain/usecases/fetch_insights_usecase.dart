import '../entities/insight_entity.dart';
import '../repositories/insights_repository.dart';

class FetchInsightsUseCase {
  const FetchInsightsUseCase(this._repo);

  final InsightsRepository _repo;

  Future<List<InsightEntity>> call() => _repo.getInsights();
}
