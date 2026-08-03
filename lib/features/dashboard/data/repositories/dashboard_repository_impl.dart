import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../../../schedule/domain/entities/dose_entity.dart';
import '../../../vitals/domain/entities/vital_reading_entity.dart';
import '../models/banner_config.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._ds);

  final DashboardRemoteDataSource _ds;

  @override
  Future<({
    DashboardStatsEntity stats,
    List<DoseEntity> doses,
    List<VitalReadingEntity> recentVitals,
    List<DashboardBanner> banners,
  })> getDashboardData() async {
    final data = await _ds.getDashboardData();
    return (
      stats: data.stats,
      doses: data.doses,
      recentVitals: data.recentVitals,
      banners: data.banners,
    );
  }
}
