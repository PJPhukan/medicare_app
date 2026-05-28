import '../../domain/entities/profile_entity.dart';

class UserProfile extends ProfileEntity {
  const UserProfile({
    required super.id,
    required super.name,
    required super.phone,
    required super.createdAt,
    super.email,
    super.profilePicture,
    super.dateOfBirth,
    super.bloodGroup,
    super.gender,
    super.address,
    super.allergies,
    super.conditions,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        createdAt: json['createdAt'] as String? ?? '',
        email: json['email'] as String?,
        profilePicture: json['profilePicture'] as String?,
        dateOfBirth: json['dateOfBirth'] as String?,
        bloodGroup: json['bloodGroup'] as String?,
        gender: json['gender'] as String?,
        address: json['address'] as String?,
        allergies:
            (json['allergies'] as List<dynamic>? ?? []).cast<String>(),
        conditions:
            (json['conditions'] as List<dynamic>? ?? []).cast<String>(),
      );
}
