// Pure domain entity for patient profiles (professional view).
// No Flutter, no JSON, no Dio.

class PatientEntity {
  const PatientEntity({
    required this.id,
    required this.name,
    required this.createdAt,
    this.phone,
    this.profilePicture,
    this.dateOfBirth,
    this.bloodGroup,
  });

  final String id;
  final String name;
  final String createdAt;
  final String? phone;
  final String? profilePicture;
  final String? dateOfBirth;
  final String? bloodGroup;

  DateTime get createdAtDate => DateTime.parse(createdAt);
  int? get age {
    if (dateOfBirth == null) return null;
    final dob = DateTime.tryParse(dateOfBirth!);
    if (dob == null) return null;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }
}
