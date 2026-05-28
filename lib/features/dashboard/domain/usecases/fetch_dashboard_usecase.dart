import '../entities/dashboard_stats_entity.dart';
import '../repositories/dashboard_repository.dart';
import '../../../schedule/domain/entities/appointment_entity.dart';
import '../../../vitals/domain/entities/vital_reading_entity.dart';
import '../../../notifications/domain/entities/notification_entity.dart';

class FetchDashboardUseCase {
  const FetchDashboardUseCase(this._repo);

  final DashboardRepository _repo;

  Future<({
    DashboardStatsEntity stats,
    List<DoseEntity> doses,
    List<VitalReadingEntity> recentVitals,
    List<NotificationEntity> notifications,
  })> call() =>
      _repo.getDashboardData();
}
