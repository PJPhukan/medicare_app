import '../../domain/entities/appointment_entity.dart';

class TodayDose extends DoseEntity {
  const TodayDose({
    required super.doseTimeId,
    required super.scheduledTime,
    required super.medicineName,
    required super.userMedicineId,
    required super.status,
    super.foodTiming,
    super.unit,
    super.quantity,
    this.log,
  });

  final TodayDoseLog? log;

  factory TodayDose.fromJson(Map<String, dynamic> json) => TodayDose(
        doseTimeId: json['doseTimeId'] as String,
        scheduledTime: json['scheduledTime'] as String,
        medicineName: json['medicineName'] as String,
        userMedicineId: json['userMedicineId'] as String,
        status: json['status'] as String,
        foodTiming: json['foodTiming'] as String?,
        unit: json['unit'] as String?,
        quantity: json['quantity'] != null
            ? (json['quantity'] as num).toDouble()
            : null,
        log: json['log'] != null
            ? TodayDoseLog.fromJson(json['log'] as Map<String, dynamic>)
            : null,
      );
}

class TodayDoseLog {
  const TodayDoseLog({required this.id, required this.status, this.takenAt});

  final String id;
  final String status;
  final String? takenAt;

  factory TodayDoseLog.fromJson(Map<String, dynamic> json) => TodayDoseLog(
        id: json['id'] as String,
        status: json['status'] as String,
        takenAt: json['takenAt'] as String?,
      );
}
