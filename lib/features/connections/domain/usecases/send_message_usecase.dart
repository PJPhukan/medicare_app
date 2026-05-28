import '../entities/chat_message_entity.dart';
import '../repositories/connections_repository.dart';

class SendConnectionMessageUseCase {
  const SendConnectionMessageUseCase(this._repo);

  final ConnectionsRepository _repo;

  Future<ChatMessageEntity> call({
    required String connectionId,
    required String body,
  }) =>
      _repo.sendMessage(connectionId: connectionId, body: body);
}
