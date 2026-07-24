// Pure domain entity for user profile.
// No Flutter, no JSON, no Dio.

class ProfileEntity {
  const ProfileEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
    this.email,
    this.profilePicture,
    this.dateOfBirth,
    this.bloodGroup,
    this.gender,
    this.address,
    this.allergies = const [],
    this.conditions = const [],
  });

  final String id;
  final String name;
  final String phone;
  final String createdAt;
  final String? email;
  final String? profilePicture;
  final String? dateOfBirth;
  final String? bloodGroup;
  final String? gender;
  final String? address;
  final List<String> allergies;
  final List<String> conditions;

  bool get hasProfilePicture => profilePicture != null;
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
