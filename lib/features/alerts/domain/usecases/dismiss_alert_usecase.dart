import '../repositories/alerts_repository.dart';

class DismissAlertUseCase {
  const DismissAlertUseCase(this._repo);

  final AlertsRepository _repo;

  Future<void> call(String id) => _repo.dismissAlert(id);
}
