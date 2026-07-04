import '../entities/connection_entity.dart';
import '../repositories/connections_repository.dart';

class FetchConnectionsAsProfessionalUseCase {
  const FetchConnectionsAsProfessionalUseCase(this._repo);

  final ConnectionsRepository _repo;

  Future<List<ConnectionEntity>> call() => _repo.getConnectionsAsProfessional();
}
