import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../../../core/network/connectivity_monitor.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/models/banner_config.dart';
import '../../data/models/dashboard_stats_model.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/fetch_dashboard_usecase.dart';
import '../../../schedule/data/models/appointment_model.dart';
import '../../../schedule/presentation/providers/schedule_provider.dart';
import '../../../schedule/domain/usecases/add_appointment_usecase.dart';
import '../../../vitals/data/models/vital_reading_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/logger.dart';

class DashboardState {
  const DashboardState({
    this.stats,
    this.doses = const [],
    this.recentVitals = const [],
    this.banners = const [],
    this.isLoading = false,
    this.error,
    this.isOffline = false,
  });

  final DashboardStats? stats;
  final List<TodayDose> doses;
  final List<VitalReading> recentVitals;
  final List<DashboardBanner> banners;
  final bool isLoading;
  final String? error;
  final bool isOffline;

  DashboardState copyWith({
    DashboardStats? stats,
    List<TodayDose>? doses,
    List<VitalReading>? recentVitals,
    List<DashboardBanner>? banners,
    bool? isLoading,
    String? error,
    bool? isOffline,
    bool clearError = false,
  }) =>
      DashboardState(
        stats: stats ?? this.stats,
        doses: doses ?? this.doses,
        recentVitals: recentVitals ?? this.recentVitals,
        banners: banners ?? this.banners,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        isOffline: isOffline ?? this.isOffline,
      );
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier(this._fetchDashboard, this._markDose, this._ref)
      : super(const DashboardState()) {
    load();
    _ref.listen<bool>(isOnlineProvider, (prev, next) {
      if (next && (prev == false || prev == null)) load();
    });
  }

  final FetchDashboardUseCase _fetchDashboard;
  final MarkDoseUseCase _markDose;
  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _fetchDashboard();
      state = state.copyWith(
        stats: data.stats as DashboardStats,
        doses: data.doses.whereType<TodayDose>().toList(),
        recentVitals: data.recentVitals.whereType<VitalReading>().toList(),
        banners: data.banners,
        isLoading: false,
        isOffline: !_ref.read(isOnlineProvider),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markDose(String doseTimeId, String status) async {
    AppLogger.i('Dose mark → id:$doseTimeId status:$status', tag: 'Dashboard');
    state = state.copyWith(
      doses: state.doses.map((d) {
        if (d.doseTimeId != doseTimeId) return d;
        return TodayDose(
          doseTimeId: d.doseTimeId,
          scheduledTime: d.scheduledTime,
          medicineName: d.medicineName,
          userMedicineId: d.userMedicineId,
          status: status,
          foodTiming: d.foodTiming,
          unit: d.unit,
          quantity: d.quantity,
        );
      }).toList(),
    );
    try {
      await _markDose(doseTimeId: doseTimeId, status: status);
      AppLogger.i('Dose marked ✓', tag: 'Dashboard');
      AppLogger.track('dose.marked', meta: {'status': status});
    } catch (e, s) {
      AppLogger.e('Dose mark failed', tag: 'Dashboard', error: e, stack: s);
      await load();
      rethrow;
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final _dashboardDsProvider = Provider<DashboardRemoteDataSource>(
  (ref) => DashboardRemoteDataSource(ref.read(dioProvider)),
);

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepositoryImpl(ref.read(_dashboardDsProvider)),
);

final _fetchDashboardUseCaseProvider = Provider<FetchDashboardUseCase>(
  (ref) => FetchDashboardUseCase(ref.read(dashboardRepositoryProvider)),
);

final _markDoseForDashProvider = Provider<MarkDoseUseCase>(
  (ref) => MarkDoseUseCase(ref.read(scheduleRepositoryProvider)),
);

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  ref.watch(authTokenProvider);
  return DashboardNotifier(
    ref.read(_fetchDashboardUseCaseProvider),
    ref.read(_markDoseForDashProvider),
    ref,
  );
});
