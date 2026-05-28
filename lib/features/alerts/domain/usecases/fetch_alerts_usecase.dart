import '../entities/alert_entity.dart';
import '../repositories/alerts_repository.dart';

class FetchAlertsUseCase {
  const FetchAlertsUseCase(this._repo);

  final AlertsRepository _repo;

  Future<List<AlertEntity>> call() => _repo.getAlerts();
}
