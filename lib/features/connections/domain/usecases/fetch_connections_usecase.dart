import '../entities/connection_entity.dart';
import '../repositories/connections_repository.dart';

class FetchConnectionsUseCase {
  const FetchConnectionsUseCase(this._repo);

  final ConnectionsRepository _repo;

  Future<List<ConnectionEntity>> call() => _repo.getConnections();
}
