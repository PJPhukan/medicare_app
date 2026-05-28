import '../../domain/entities/patient_entity.dart';

class Patient extends PatientEntity {
  const Patient({
    required super.id,
    required super.name,
    required super.createdAt,
    super.phone,
    super.profilePicture,
    super.dateOfBirth,
    super.bloodGroup,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        createdAt: json['createdAt'] as String,
        phone: json['phone'] as String?,
        profilePicture: json['profilePicture'] as String?,
        dateOfBirth: json['dateOfBirth'] as String?,
        bloodGroup: json['bloodGroup'] as String?,
      );
}
