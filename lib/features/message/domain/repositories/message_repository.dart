import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

abstract interface class MessageRepository {
  Future<List<ConversationEntity>> getConversations();
  Future<List<MessageEntity>> getThread(String conversationId);
  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String body,
  });
}
