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

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        name: entity.name,
        phone: entity.phone,
        email: entity.email,
        avatarUrl: entity.avatarUrl,
        isActive: entity.isActive,
        theme: entity.theme,
        createdAt: entity.createdAt,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String) throw const FormatException('Invalid user id');
    final rawTheme = (json['theme'] as String? ?? 'SYSTEM').toLowerCase();
    final createdAtStr = json['createdAt'] as String?;
    return UserModel(
      id: id,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      theme: UserTheme.values.firstWhere(
        (t) => t.name == rawTheme,
        orElse: () => UserTheme.system,
      ),
      createdAt: createdAtStr != null ? DateTime.tryParse(createdAtStr) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'avatarUrl': avatarUrl,
        'isActive': isActive,
        'theme': theme.name.toUpperCase(),
        'createdAt': createdAt?.toIso8601String(),
      };
}
