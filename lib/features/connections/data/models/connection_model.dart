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
        profilePicture: json['profilePicture'] as String?,
        phone: json['phone'] as String?,
      );
}

class Connection extends ConnectionEntity {
  const Connection({
    required super.id,
    required ConnectionUser connectedUser,
    required super.createdAt,
    super.lastMessageAt,
  }) : super(connectedUser: connectedUser);

  @override
  ConnectionUser get connectedUser => super.connectedUser as ConnectionUser;

  factory Connection.fromJson(Map<String, dynamic> json) => Connection(
        id: json['id'] as String,
        connectedUser: ConnectionUser.fromJson(
          json['connectedUser'] as Map<String, dynamic>,
        ),
        createdAt: json['createdAt'] as String,
        lastMessageAt: json['lastMessageAt'] as String?,
      );
}
