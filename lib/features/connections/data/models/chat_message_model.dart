import '../../domain/entities/chat_message_entity.dart';

class ChatMessage extends ChatMessageEntity {
  const ChatMessage({
    required super.id,
    required super.connectionId,
    required super.senderId,
    required super.body,
    required super.createdAt,
    super.readAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        connectionId: json['connectionId'] as String,
        senderId: json['senderId'] as String,
        body: json['body'] as String,
        createdAt: json['createdAt'] as String,
        readAt: json['readAt'] as String?,
      );
}
