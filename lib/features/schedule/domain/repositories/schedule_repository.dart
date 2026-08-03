import '../entities/dose_entity.dart';

abstract interface class ScheduleRepository {
  Future<List<DoseEntity>> getTodayDoses({String? date});

  Future<void> markDose({
    required String doseTimeId,
    required String status,
    String? scheduledDate,
    String? skippedReason,
  });
}
