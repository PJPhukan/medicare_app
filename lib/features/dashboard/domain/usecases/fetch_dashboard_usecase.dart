import '../entities/dashboard_stats_entity.dart';
import '../repositories/dashboard_repository.dart';
import '../../../schedule/domain/entities/dose_entity.dart';
import '../../../vitals/domain/entities/vital_reading_entity.dart';
import '../../data/models/banner_config.dart';

class FetchDashboardUseCase {
  const FetchDashboardUseCase(this._repo);

  final DashboardRepository _repo;

  Future<({
    DashboardStatsEntity stats,
    List<DoseEntity> doses,
    List<VitalReadingEntity> recentVitals,
    List<DashboardBanner> banners,
  })> call() =>
      _repo.getDashboardData();
}
