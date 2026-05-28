import '../entities/message_entity.dart';
import '../repositories/message_repository.dart';

class SendMessageUseCase {
  const SendMessageUseCase(this._repo);

  final MessageRepository _repo;

  Future<MessageEntity> call({
    required String conversationId,
    required String body,
  }) =>
      _repo.sendMessage(conversationId: conversationId, body: body);
}
