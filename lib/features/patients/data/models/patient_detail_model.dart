import '../../domain/entities/patient_detail_entity.dart';

class PatientVitalSummary extends PatientVitalSummaryEntity {
  const PatientVitalSummary({
    required super.type,
    required super.latestValue,
    required super.unit,
    required super.measuredAt,
  });

  factory PatientVitalSummary.fromJson(Map<String, dynamic> json) =>
      PatientVitalSummary(
        type: json['type'] as String,
        latestValue: (json['latestValue'] as num).toDouble(),
        unit: json['unit'] as String,
        measuredAt: json['measuredAt'] as String,
      );
}

class PatientDetail extends PatientDetailEntity {
  const PatientDetail({
    required super.id,
    required super.name,
    required super.createdAt,
    required List<PatientVitalSummary> vitalSummaries,
    required super.activeMedicineCount,
    super.phone,
    super.profilePicture,
    super.dateOfBirth,
    super.bloodGroup,
    super.allergies,
    super.conditions,
  }) : super(vitalSummaries: vitalSummaries);

  @override
  List<PatientVitalSummary> get vitalSummaries =>
      super.vitalSummaries.cast<PatientVitalSummary>();

  factory PatientDetail.fromJson(Map<String, dynamic> json) => PatientDetail(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        createdAt: json['createdAt'] as String,
        phone: json['phone'] as String?,
        profilePicture: json['profilePicture'] as String?,
        dateOfBirth: json['dateOfBirth'] as String?,
        bloodGroup: json['bloodGroup'] as String?,
        activeMedicineCount: json['activeMedicineCount'] as int? ?? 0,
        allergies:
            (json['allergies'] as List<dynamic>? ?? []).cast<String>(),
        conditions:
            (json['conditions'] as List<dynamic>? ?? []).cast<String>(),
        vitalSummaries: (json['vitalSummaries'] as List<dynamic>? ?? [])
            .map((e) =>
                PatientVitalSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
