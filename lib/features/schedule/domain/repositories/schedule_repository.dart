import '../entities/appointment_entity.dart';

abstract interface class ScheduleRepository {
  Future<List<DoseEntity>> getTodayDoses();

  Future<void> markDose({
    required String doseTimeId,
    required String status,
    String? skippedReason,
  });
}
