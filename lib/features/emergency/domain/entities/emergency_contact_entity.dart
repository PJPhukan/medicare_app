// Pure domain entity for emergency contacts.
// No Flutter, no JSON, no Dio.

class EmergencyContactEntity {
  const EmergencyContactEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
    this.relationship,
    this.isPrimary = false,
    this.priority = 0,
  });

  final String id;
  final String name;
  final String phone;
  final String createdAt;
  final String? relationship;
  final bool isPrimary;

  /// Lower = contacted first (v1 notifies everyone; used for display order).
  final int priority;

  DateTime get createdAtDate => DateTime.parse(createdAt);
}
