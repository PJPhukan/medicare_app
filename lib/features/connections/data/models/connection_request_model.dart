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
        // backend uses avatarUrl on the user relation
        profilePicture:
            json['avatarUrl'] as String? ?? json['profilePicture'] as String?,
        phone: json['phone'] as String?,
      );
}

class ConnectionRequestProfessional extends ConnectionRequestProfessionalEntity {
  const ConnectionRequestProfessional({
    required super.id,
    required super.displayName,
    super.profileImageUrl,
  });

  factory ConnectionRequestProfessional.fromJson(Map<String, dynamic> json) =>
      ConnectionRequestProfessional(
        id: json['id'] as String,
        displayName: json['displayName'] as String? ?? 'Professional',
        profileImageUrl: json['profileImageUrl'] as String?,
      );
}

class ConnectionRequest extends ConnectionRequestEntity {
  const ConnectionRequest({
    required super.id,
    required super.status,
    required super.planType,
    required super.amount,
    required super.createdAt,
    required ConnectionRequestUser user,
    required ConnectionRequestProfessional professional,
    super.note,
  }) : super(user: user, professional: professional);

  @override
  ConnectionRequestUser get user => super.user as ConnectionRequestUser;

  @override
  ConnectionRequestProfessional get professional =>
      super.professional as ConnectionRequestProfessional;

  factory ConnectionRequest.fromJson(Map<String, dynamic> json) =>
      ConnectionRequest(
        id: json['id'] as String,
        status: json['status'] as String,
        planType: json['planType'] as String? ?? 'HOURLY',
        amount: (json['amount'] as num?)?.toInt() ?? 0,
        createdAt: json['createdAt'] as String,
        note: json['note'] as String?,
        user: ConnectionRequestUser.fromJson(
          json['user'] as Map<String, dynamic>,
        ),
        professional: ConnectionRequestProfessional.fromJson(
          json['professional'] as Map<String, dynamic>,
        ),
      );
}
