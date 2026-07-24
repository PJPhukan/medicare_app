import '../../domain/entities/emergency_profile_entity.dart';

class EmergencyProfile extends EmergencyProfileEntity {
  const EmergencyProfile({
    super.bloodGroup,
    super.allergies,
    super.conditions,
    super.medications,
    super.notes,
  });

  // allergies/medications/conditions are free-form Json columns on the
  // backend — parse defensively and keep only string entries.
  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList();
  }

  factory EmergencyProfile.fromJson(Map<String, dynamic> json) =>
      EmergencyProfile(
        bloodGroup: json['bloodGroup'] as String?,
        allergies: _stringList(json['allergies']),
        conditions: _stringList(json['conditions']),
        medications: _stringList(json['medications']),
        notes: json['notes'] as String?,
      );
}
