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

  UserEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
    bool? isActive,
    UserTheme? theme,
    DateTime? createdAt,
  }) =>
      UserEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isActive: isActive ?? this.isActive,
        theme: theme ?? this.theme,
        createdAt: createdAt ?? this.createdAt,
      );

  /// True when the user has actually set a name.
  bool get hasName => name != null && name!.trim().isNotEmpty;

  /// Name for profile cards, avatars and initials.
  ///
  /// Deliberately does NOT fall back to email or phone: an address is not a
  /// name, and that fallback leaked the raw email into the dashboard
  /// greeting, the avatar initials, the settings profile card (next to the
  /// email itself) and the spoken dose reminder.
  String get displayName => hasName ? name!.trim() : 'User';

  /// First name, for greetings and the spoken reminder. Falls back to a
  /// friendly generic rather than a placeholder noun — "Good evening, there"
  /// reads, "Good evening, User" doesn't.
  String get greetingName =>
      hasName ? name!.trim().split(RegExp(r'\s+')).first : 'there';
}
