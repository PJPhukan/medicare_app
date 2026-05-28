import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/message_remote_datasource.dart';

class MessageRepositoryImpl implements MessageRepository {
  const MessageRepositoryImpl(this._ds);

  final MessageRemoteDataSource _ds;

  @override
  Future<List<ConversationEntity>> getConversations() async {
    final List<ConversationEntity> list = await _ds.getConversations();
    return list;
  }

  @override
  Future<List<MessageEntity>> getThread(String conversationId) async {
    final List<MessageEntity> list = await _ds.getThread(conversationId);
    return list;
  }

  @override
  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    final MessageEntity msg =
        await _ds.sendMessage(conversationId: conversationId, body: body);
    return msg;
  }
}
