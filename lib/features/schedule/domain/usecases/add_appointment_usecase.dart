import '../repositories/schedule_repository.dart';

class MarkDoseUseCase {
  const MarkDoseUseCase(this._repository);

  final ScheduleRepository _repository;

  Future<void> call({
    required String doseTimeId,
    required String status,
    String? skippedReason,
  }) =>
      _repository.markDose(
        doseTimeId: doseTimeId,
        status: status,
        skippedReason: skippedReason,
      );
}
