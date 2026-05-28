// Pure domain entity for connection requests.
// No Flutter, no JSON, no Dio.

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

class ConnectionRequestEntity {
  const ConnectionRequestEntity({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.sender,
    required this.receiver,
  });

  final String id;
  final String status; // 'PENDING' | 'ACCEPTED' | 'DECLINED'
  final String createdAt;
  final ConnectionRequestUserEntity sender;
  final ConnectionRequestUserEntity receiver;

  bool get isPending => status == 'PENDING';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isDeclined => status == 'DECLINED';
  DateTime get createdAtDate => DateTime.parse(createdAt);
}
