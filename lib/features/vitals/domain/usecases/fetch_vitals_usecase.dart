import '../entities/vital_reading_entity.dart';
import '../repositories/vitals_repository.dart';

class FetchVitalsUseCase {
  const FetchVitalsUseCase(this._repository);

  final VitalsRepository _repository;

  Future<List<VitalReadingEntity>> call() => _repository.getMyVitals();
}
