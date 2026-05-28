import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.isActive,
    required super.theme,
    required super.createdAt,
    super.name,
    super.phone,
    super.email,
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        theme: json['theme'] as String? ?? 'SYSTEM',
        createdAt: json['createdAt'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'avatarUrl': avatarUrl,
        'isActive': isActive,
        'theme': theme,
        'createdAt': createdAt,
      };
}
