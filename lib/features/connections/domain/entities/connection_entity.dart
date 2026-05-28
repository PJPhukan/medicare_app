// Pure domain entity for user connections.
// No Flutter, no JSON, no Dio.

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

class ConnectionEntity {
  const ConnectionEntity({
    required this.id,
    required this.connectedUser,
    required this.createdAt,
    this.lastMessageAt,
  });

  final String id;
  final ConnectionUserEntity connectedUser;
  final String createdAt;
  final String? lastMessageAt;

  DateTime get createdAtDate => DateTime.parse(createdAt);
  bool get hasRecentMessage => lastMessageAt != null;
}
