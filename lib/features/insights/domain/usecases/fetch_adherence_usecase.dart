import '../entities/adherence_entity.dart';
import '../repositories/insights_repository.dart';

class FetchAdherenceUseCase {
  const FetchAdherenceUseCase(this._repo);

  final InsightsRepository _repo;

  Future<AdherenceEntity> call({int periodDays = 7}) =>
      _repo.getAdherence(periodDays: periodDays);
}
