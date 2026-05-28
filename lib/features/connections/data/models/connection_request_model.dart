import '../../domain/entities/connection_request_entity.dart';

class ConnectionRequestUser extends ConnectionRequestUserEntity {
  const ConnectionRequestUser({
    required super.id,
    required super.name,
    super.profilePicture,
    super.phone,
  });

  factory ConnectionRequestUser.fromJson(Map<String, dynamic> json) =>
      ConnectionRequestUser(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        profilePicture: json['profilePicture'] as String?,
        phone: json['phone'] as String?,
      );
}

class ConnectionRequest extends ConnectionRequestEntity {
  const ConnectionRequest({
    required super.id,
    required super.status,
    required super.createdAt,
    required ConnectionRequestUser sender,
    required ConnectionRequestUser receiver,
  }) : super(sender: sender, receiver: receiver);

  @override
  ConnectionRequestUser get sender =>
      super.sender as ConnectionRequestUser;

  @override
  ConnectionRequestUser get receiver =>
      super.receiver as ConnectionRequestUser;

  factory ConnectionRequest.fromJson(Map<String, dynamic> json) =>
      ConnectionRequest(
        id: json['id'] as String,
        status: json['status'] as String,
        createdAt: json['createdAt'] as String,
        sender: ConnectionRequestUser.fromJson(
          json['sender'] as Map<String, dynamic>,
        ),
        receiver: ConnectionRequestUser.fromJson(
          json['receiver'] as Map<String, dynamic>,
        ),
      );
}
