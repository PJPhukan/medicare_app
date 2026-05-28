import '../../domain/entities/conversation_entity.dart';

class ConversationParticipant extends ConversationParticipantEntity {
  const ConversationParticipant({
    required super.id,
    required super.name,
    super.profilePicture,
  });

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) =>
      ConversationParticipant(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        profilePicture: json['profilePicture'] as String?,
      );
}

class Conversation extends ConversationEntity {
  const Conversation({
    required super.id,
    required List<ConversationParticipant> participants,
    required super.createdAt,
    super.lastMessage,
    super.lastMessageAt,
    super.unreadCount,
  }) : super(participants: participants);

  @override
  List<ConversationParticipant> get participants =>
      super.participants.cast<ConversationParticipant>();

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] as String,
        createdAt: json['createdAt'] as String,
        lastMessage: json['lastMessage'] as String?,
        lastMessageAt: json['lastMessageAt'] as String?,
        unreadCount: json['unreadCount'] as int? ?? 0,
        participants: (json['participants'] as List<dynamic>? ?? [])
            .map((e) =>
                ConversationParticipant.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
