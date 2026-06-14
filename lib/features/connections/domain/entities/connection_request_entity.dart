// Pure domain entity for connection requests.
// No Flutter, no JSON, no Dio.
//
// Matches the backend `requestSelect` shape: a request always has a `user`
// (the patient who sent it) and a `professional` (the target). The same entity
// powers both the patient's "Sent" tab and the professional's "Requests" inbox.

class ConnectionRequestUserEntity {
  const ConnectionRequestUserEntity({
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

class ConnectionRequestProfessionalEntity {
  const ConnectionRequestProfessionalEntity({
    required this.id,
    required this.displayName,
    this.profileImageUrl,
  });

  final String id;
  final String displayName;
  final String? profileImageUrl;
}

class ConnectionRequestEntity {
  const ConnectionRequestEntity({
    required this.id,
    required this.status,
    required this.planType,
    required this.amount,
    required this.createdAt,
    required this.user,
    required this.professional,
    this.note,
  });

  final String id;
  final String status; // PENDING | ACCEPTED | DECLINED | EXPIRED | CANCELLED
  final String planType; // HOURLY | DAILY | MONTHLY
  final int amount;
  final String createdAt;
  final String? note;
  final ConnectionRequestUserEntity user; // the patient who requested
  final ConnectionRequestProfessionalEntity professional; // the target pro

  bool get isPending => status == 'PENDING';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isDeclined => status == 'DECLINED';
  bool get isExpired => status == 'EXPIRED';
  DateTime get createdAtDate => DateTime.parse(createdAt);
}
