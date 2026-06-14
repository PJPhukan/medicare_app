import '../../data/models/create_request_result.dart';
import '../repositories/connections_repository.dart';

class PayForRequestUseCase {
  const PayForRequestUseCase(this._repo);

  final ConnectionsRepository _repo;

  Future<CreateRequestResult> call(String requestId) =>
      _repo.payForRequest(requestId);
}
