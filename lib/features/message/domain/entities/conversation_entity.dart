// Pure domain entity for messaging conversations.
// No Flutter, no JSON, no Dio.

class ConversationParticipantEntity {
  const ConversationParticipantEntity({
    required this.id,
    required this.name,
    this.profilePicture,
  });

  final String id;
  final String name;
  final String? profilePicture;
}

class ConversationEntity {
  const ConversationEntity({
    required this.id,
    required this.participants,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  final String id;
  final List<ConversationParticipantEntity> participants;
  final String createdAt;
  final String? lastMessage;
  final String? lastMessageAt;
  final int unreadCount;

  bool get hasUnread => unreadCount > 0;
  DateTime get createdAtDate => DateTime.parse(createdAt);
}
