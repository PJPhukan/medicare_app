import '../entities/conversation_entity.dart';
import '../repositories/message_repository.dart';

class FetchConversationsUseCase {
  const FetchConversationsUseCase(this._repo);

  final MessageRepository _repo;

  Future<List<ConversationEntity>> call() => _repo.getConversations();
}
