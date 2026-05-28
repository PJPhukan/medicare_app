import '../entities/alert_entity.dart';

abstract interface class AlertsRepository {
  Future<List<AlertEntity>> getAlerts();
  Future<void> dismissAlert(String id);
}
