enum UserTheme { light, dark, system }

class UserEntity {
  const UserEntity({
    required this.id,
    required this.isActive,
    required this.theme,
    this.createdAt,
    this.name,
    this.phone,
    this.email,
    this.avatarUrl,
  });

  final String id;
  final String? name;
  final String? phone;
  final String? email;
  final String? avatarUrl;
  final bool isActive;
  final UserTheme theme;
  final DateTime? createdAt;

  String get displayName => name ?? phone ?? email ?? 'User';
}
