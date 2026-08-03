/// Pure domain entity for a today's dose. No Flutter, no JSON, no Dio.
class DoseEntity {
  const DoseEntity({
    required this.doseTimeId,
    required this.scheduledTime,
    required this.medicineName,
    required this.userMedicineId,
    required this.status,
    this.foodTiming,
    this.unit,
    this.quantity,
  });

  final String doseTimeId;
  final String scheduledTime;
  final String medicineName;
  final String userMedicineId;
  final String status;
  final String? foodTiming;
  final String? unit;
  final double? quantity;

  bool get isTaken   => status == 'TAKEN';
  bool get isSkipped => status == 'SKIPPED';
  bool get isPending => status == 'PENDING';
  bool get isMissed  => status == 'MISSED';
}
