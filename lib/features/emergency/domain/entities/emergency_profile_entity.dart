// Pure domain entity for the emergency health profile.
// No Flutter, no JSON, no Dio.

class EmergencyProfileEntity {
  const EmergencyProfileEntity({
    this.bloodGroup,
    this.allergies = const [],
    this.conditions = const [],
    this.medications = const [],
    this.notes,
  });

  final String? bloodGroup;
  final List<String> allergies;
  final List<String> conditions;
  final List<String> medications;
  final String? notes;

  bool get isEmpty =>
      bloodGroup == null &&
      allergies.isEmpty &&
      conditions.isEmpty &&
      medications.isEmpty &&
      notes == null;
}
