// Pure domain entity for messages within a conversation.
// No Flutter, no JSON, no Dio.

class MessageEntity {
  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    required this.createdAt,
    this.readAt,
    this.attachment,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String body;
  final String createdAt;
  final String? readAt;
  final String? attachment;

  bool get isRead => readAt != null;
  bool get hasAttachment => attachment != null;
  DateTime get createdAtDate => DateTime.parse(createdAt);
}
