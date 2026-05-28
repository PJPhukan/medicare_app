import '../entities/vital_config_entity.dart';
import '../repositories/vitals_repository.dart';

class FetchVitalConfigsUseCase {
  const FetchVitalConfigsUseCase(this._repository);

  final VitalsRepository _repository;

  Future<List<VitalConfigEntity>> call() => _repository.getConfigs();
}
