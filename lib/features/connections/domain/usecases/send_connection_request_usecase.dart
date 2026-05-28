import '../repositories/connections_repository.dart';

class SendConnectionRequestUseCase {
  const SendConnectionRequestUseCase(this._repo);

  final ConnectionsRepository _repo;

  Future<void> call(String targetUserId) =>
      _repo.sendConnectionRequest(targetUserId);
}
