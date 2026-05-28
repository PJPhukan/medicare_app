import '../entities/vital_reading_entity.dart';
import '../repositories/vitals_repository.dart';

class AddVitalReadingUseCase {
  const AddVitalReadingUseCase(this._repository);

  final VitalsRepository _repository;

  Future<VitalReadingEntity> call({
    required String vitalConfigId,
    required List<Map<String, dynamic>> values,
    String? measuredAt,
    String? notes,
  }) =>
      _repository.addReading(
        vitalConfigId: vitalConfigId,
        values: values,
        measuredAt: measuredAt,
        notes: notes,
      );
}
