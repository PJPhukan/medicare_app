import '../entities/vital_reading_entity.dart';
import '../repositories/vitals_repository.dart';

class FetchVitalHistoryUseCase {
  const FetchVitalHistoryUseCase(this._repository);

  final VitalsRepository _repository;

  Future<({List<VitalReadingEntity> readings, String? nextCursor})> call({
    required String configId,
    required String filter,
    String? cursor,
    int limit = 20,
  }) =>
      _repository.getVitalHistory(
        configId: configId,
        filter: filter,
        cursor: cursor,
        limit: limit,
      );
}
