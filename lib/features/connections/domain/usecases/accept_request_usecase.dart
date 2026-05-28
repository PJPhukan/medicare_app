import '../repositories/connections_repository.dart';

class AcceptRequestUseCase {
  const AcceptRequestUseCase(this._repo);

  final ConnectionsRepository _repo;

  Future<void> call(String requestId) => _repo.acceptRequest(requestId);
}
