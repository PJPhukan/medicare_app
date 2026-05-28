// Pure domain entity for detailed patient profile.
// No Flutter, no JSON, no Dio.

import 'patient_entity.dart';

class PatientVitalSummaryEntity {
  const PatientVitalSummaryEntity({
    required this.type,
    required this.latestValue,
    required this.unit,
    required this.measuredAt,
  });

  final String type;
  final double latestValue;
  final String unit;
  final String measuredAt;

  DateTime get measuredAtDate => DateTime.parse(measuredAt);
}

class PatientDetailEntity extends PatientEntity {
  const PatientDetailEntity({
    required super.id,
    required super.name,
    required super.createdAt,
    required this.vitalSummaries,
    required this.activeMedicineCount,
    super.phone,
    super.profilePicture,
    super.dateOfBirth,
    super.bloodGroup,
    this.allergies = const [],
    this.conditions = const [],
  });

  final List<PatientVitalSummaryEntity> vitalSummaries;
  final int activeMedicineCount;
  final List<String> allergies;
  final List<String> conditions;

  bool get hasVitals => vitalSummaries.isNotEmpty;
}
