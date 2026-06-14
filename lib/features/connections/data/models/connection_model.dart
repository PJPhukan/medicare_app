import '../../domain/entities/connection_entity.dart';

class ConnectionUser extends ConnectionUserEntity {
  const ConnectionUser({
    required super.id,
    required super.name,
    super.profilePicture,
    super.phone,
  });

  factory ConnectionUser.fromJson(Map<String, dynamic> json) => ConnectionUser(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        profilePicture:
            json['avatarUrl'] as String? ?? json['profilePicture'] as String?,
        phone: json['phone'] as String?,
      );
}

class ConnectionProfessional extends ConnectionProfessionalEntity {
  const ConnectionProfessional({
    required super.id,
    required super.displayName,
    super.profileImageUrl,
    super.userId,
  });

  factory ConnectionProfessional.fromJson(Map<String, dynamic> json) =>
      ConnectionProfessional(
        id: json['id'] as String,
        displayName: json['displayName'] as String? ?? 'Professional',
        profileImageUrl: json['profileImageUrl'] as String?,
        userId: (json['user'] as Map<String, dynamic>?)?['id'] as String?,
      );
}

class Connection extends ConnectionEntity {
  const Connection({
    required super.id,
    required super.status,
    required super.planType,
    required ConnectionUser user,
    required ConnectionProfessional professional,
    required super.createdAt,
    super.startedAt,
    super.expiresAt,
    super.lastMessageAt,
  }) : super(user: user, professional: professional);

  factory Connection.fromJson(Map<String, dynamic> json) => Connection(
        id: json['id'] as String,
        status: json['status'] as String? ?? 'ACTIVE',
        planType: json['planType'] as String? ?? 'HOURLY',
        user: ConnectionUser.fromJson(json['user'] as Map<String, dynamic>),
        professional: ConnectionProfessional.fromJson(
          json['professional'] as Map<String, dynamic>,
        ),
        createdAt: json['createdAt'] as String,
        startedAt: json['startedAt'] as String?,
        expiresAt: json['expiresAt'] as String?,
        lastMessageAt: json['lastMessageAt'] as String?,
      );
}
