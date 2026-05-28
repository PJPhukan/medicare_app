import '../../domain/entities/message_entity.dart';

class Message extends MessageEntity {
  const Message({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.body,
    required super.createdAt,
    super.readAt,
    super.attachment,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as String,
        conversationId: json['conversationId'] as String,
        senderId: json['senderId'] as String,
        body: json['body'] as String,
        createdAt: json['createdAt'] as String,
        readAt: json['readAt'] as String?,
        attachment: json['attachment'] as String?,
      );
}
