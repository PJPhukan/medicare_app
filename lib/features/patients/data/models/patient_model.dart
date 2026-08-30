import '../../domain/entities/patient_entity.dart';

class Patient extends PatientEntity {
  const Patient({
    required super.id,
    required super.name,
    required super.createdAt,
    super.relation,
    super.selfUserId,
    super.invitePhone,
    super.inviteEmail,
    super.selfUserName,
    super.selfUserPhone,
    super.selfUserEmail,
    super.avatarUrl,
    super.dateOfBirth,
    super.bloodGroup,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    final selfUser = json['selfUser'] as Map<String, dynamic>?;
    return Patient(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      createdAt: json['createdAt'] as String,
      relation: json['relation'] as String?,
      selfUserId: json['selfUserId'] as String?,
      invitePhone: json['invitePhone'] as String?,
      inviteEmail: json['inviteEmail'] as String?,
      selfUserName: selfUser?['name'] as String?,
      selfUserPhone: selfUser?['phone'] as String?,
      selfUserEmail: selfUser?['email'] as String?,
      avatarUrl: selfUser?['avatarUrl'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
    );
  }
}
