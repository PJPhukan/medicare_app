import '../entities/message_entity.dart';
import '../repositories/message_repository.dart';

class FetchThreadUseCase {
  const FetchThreadUseCase(this._repo);

  final MessageRepository _repo;

  Future<List<MessageEntity>> call(String conversationId) =>
      _repo.getThread(conversationId);
}
