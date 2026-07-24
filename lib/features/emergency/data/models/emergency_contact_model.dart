import '../../domain/entities/emergency_contact_entity.dart';

class EmergencyContact extends EmergencyContactEntity {
  const EmergencyContact({
    required super.id,
    required super.name,
    required super.phone,
    required super.createdAt,
    super.relationship,
    super.isPrimary,
    super.priority,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        createdAt: json['createdAt'] as String,
        // Backend field is `relation`; accept `relationship` for older payloads.
        relationship: (json['relation'] ?? json['relationship']) as String?,
        isPrimary: json['isPrimary'] as bool? ?? false,
        priority: json['priority'] as int? ?? 0,
      );
}
