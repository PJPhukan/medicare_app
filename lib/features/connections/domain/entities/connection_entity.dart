// Pure domain entity for user connections.
// No Flutter, no JSON, no Dio.
//
// Matches the backend `connectionSelect` shape: a connection has a `user`
// (the patient) and a `professional`. For the patient app the "connected user"
// shown in the UI is the professional, exposed via [connectedUser].

class ConnectionUserEntity {
  const ConnectionUserEntity({
    required this.id,
    required this.name,
    this.profilePicture,
    this.phone,
  });

  final String id;
  final String name;
  final String? profilePicture;
  final String? phone;
}

class ConnectionProfessionalEntity {
  const ConnectionProfessionalEntity({
    required this.id,
    required this.displayName,
    this.profileImageUrl,
    this.userId,
  });

  final String id;
  final String displayName;
  final String? profileImageUrl;
  final String? userId;
}

class ConnectionEntity {
  const ConnectionEntity({
    required this.id,
    required this.status,
    required this.planType,
    required this.user,
    required this.professional,
    required this.createdAt,
    this.startedAt,
    this.expiresAt,
    this.lastMessageAt,
  });

  final String id;
  final String status; // ACTIVE | EXPIRED | CANCELLED
  final String planType; // HOURLY | DAILY | MONTHLY
  final ConnectionUserEntity user; // the patient
  final ConnectionProfessionalEntity professional;
  final String createdAt;
  final String? startedAt;
  final String? expiresAt;
  final String? lastMessageAt;

  /// The counterpart shown to the patient — i.e. the professional.
  ConnectionUserEntity get connectedUser => ConnectionUserEntity(
        id: professional.id,
        name: professional.displayName,
        profilePicture: professional.profileImageUrl,
      );

  bool get isActive => status == 'ACTIVE';
  DateTime get createdAtDate => DateTime.parse(createdAt);
  bool get hasRecentMessage => lastMessageAt != null;
}
