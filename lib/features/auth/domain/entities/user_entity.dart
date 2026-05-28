class UserEntity {
  const UserEntity({
    required this.id,
    required this.isActive,
    required this.theme,
    required this.createdAt,
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
  final String theme;
  final String createdAt;

  String get displayName => name ?? phone ?? email ?? 'User';
}
