import '../entities/vital_reading_entity.dart';
import '../repositories/vitals_repository.dart';

class UpdateVitalReadingUseCase {
  const UpdateVitalReadingUseCase(this._repository);

  final VitalsRepository _repository;

  Future<VitalReadingEntity> call({
    required String id,
    required List<Map<String, dynamic>> values,
    String? measuredAt,
    String? notes,
  }) =>
      _repository.updateReading(
        id: id,
        values: values,
        measuredAt: measuredAt,
        notes: notes,
      );
}
