import '../entities/connection_request_entity.dart';
import '../repositories/connections_repository.dart';

class GetMyRequestsUseCase {
  const GetMyRequestsUseCase(this._repo);

  final ConnectionsRepository _repo;

  Future<List<ConnectionRequestEntity>> call() => _repo.getMyRequests();
}
