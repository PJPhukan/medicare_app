import '../../domain/entities/alert_entity.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../datasources/alerts_remote_datasource.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  const AlertsRepositoryImpl(this._ds);

  final AlertsRemoteDataSource _ds;

  @override
  Future<List<AlertEntity>> getAlerts() async {
    final List<AlertEntity> alerts = await _ds.getAlerts();
    return alerts;
  }

  @override
  Future<void> dismissAlert(String id) => _ds.dismissAlert(id);
}
