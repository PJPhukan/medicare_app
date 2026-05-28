import '../repositories/connections_repository.dart';

class DeclineRequestUseCase {
  const DeclineRequestUseCase(this._repo);

  final ConnectionsRepository _repo;

  Future<void> call(String requestId) => _repo.declineRequest(requestId);
}
