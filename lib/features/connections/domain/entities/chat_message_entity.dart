// Pure domain entity for chat messages between connections.
// No Flutter, no JSON, no Dio.

class ChatMessageEntity {
  const ChatMessageEntity({
    required this.id,
    required this.connectionId,
    required this.senderId,
    required this.body,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String connectionId;
  final String senderId;
  final String body;
  final String createdAt;
  final String? readAt;

  bool get isRead => readAt != null;
  DateTime get createdAtDate => DateTime.parse(createdAt);
}
