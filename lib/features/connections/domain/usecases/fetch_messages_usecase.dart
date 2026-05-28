import '../entities/chat_message_entity.dart';
import '../repositories/connections_repository.dart';

class FetchMessagesUseCase {
  const FetchMessagesUseCase(this._repo);

  final ConnectionsRepository _repo;

  Future<List<ChatMessageEntity>> call(String connectionId) =>
      _repo.getMessages(connectionId);
}
