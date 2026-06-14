import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../../../core/local_db/sync_queue.dart';
import '../../../../core/network/connectivity_monitor.dart';
import '../../data/datasources/schedule_remote_datasource.dart';
import '../../data/models/appointment_model.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/usecases/fetch_schedule_usecase.dart';
import '../../domain/usecases/add_appointment_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/logger.dart';

class ScheduleState {
  const ScheduleState({
    this.doses = const [],
    this.isLoading = false,
    this.error,
    this.isOffline = false,
  });

  final List<TodayDose> doses;
  final bool isLoading;
  final String? error;
  final bool isOffline;

  ScheduleState copyWith({
    List<TodayDose>? doses,
    bool? isLoading,
    String? error,
    bool? isOffline,
    bool clearError = false,
  }) =>
      ScheduleState(
        doses: doses ?? this.doses,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        isOffline: isOffline ?? this.isOffline,
      );
}

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  ScheduleNotifier(
    this._fetchDoses,
    this._markDose,
    this._ref,
  ) : super(const ScheduleState()) {
    load();
    // Refresh automatically when connectivity is restored
    _ref.listen<bool>(isOnlineProvider, (prev, next) {
      if (next && (prev == false || prev == null)) load();
    });
  }

  final FetchScheduleUseCase _fetchDoses;
  final MarkDoseUseCase _markDose;
  final Ref _ref;

  /// The calendar date currently being viewed. Kept so connectivity-triggered
  /// refreshes re-fetch the same day rather than snapping back to today.
  DateTime _currentDate = DateTime.now();

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static bool _isToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  Future<void> load({DateTime? date}) async {
    if (date != null) _currentDate = date;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // CacheInterceptor returns cached JSON automatically when offline.
      // Today is fetched without a date param so existing caches stay warm.
      final entities = await _fetchDoses(
        date: _isToday(_currentDate) ? null : _dateKey(_currentDate),
      );
      state = state.copyWith(
        doses: entities.whereType<TodayDose>().toList(),
        isLoading: false,
        isOffline: !_ref.read(isOnlineProvider),
      );
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markDose(String doseTimeId, String status) async {
    AppLogger.i('Dose mark → id:$doseTimeId status:$status', tag: 'Schedule');
    // 1. Optimistic local update
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

    // 2. Persist via repository (online → API, offline → SyncQueue).
    // Stamp the log with the viewed date so back-dated marks land correctly.
    try {
      await _markDose(
        doseTimeId: doseTimeId,
        status: status,
        scheduledDate: _isToday(_currentDate) ? null : _dateKey(_currentDate),
      );
      AppLogger.i('Dose marked ✓', tag: 'Schedule');
      AppLogger.track('dose.marked', meta: {'status': status});
    } on Exception catch (e, s) {
      AppLogger.e('Dose mark failed', tag: 'Schedule', error: e, stack: s);
      await load(); // revert on failure
      rethrow;
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final _scheduleDsProvider = Provider<ScheduleRemoteDataSource>(
  (ref) => ScheduleRemoteDataSource(ref.read(dioProvider)),
);

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) =>
    ScheduleRepositoryImpl(
      ref.read(_scheduleDsProvider),
      ref.read(syncQueueProvider),
      () => ref.read(isOnlineProvider),
    ));

final _fetchScheduleUseCaseProvider = Provider<FetchScheduleUseCase>(
  (ref) => FetchScheduleUseCase(ref.read(scheduleRepositoryProvider)),
);

final _markDoseUseCaseProvider = Provider<MarkDoseUseCase>(
  (ref) => MarkDoseUseCase(ref.read(scheduleRepositoryProvider)),
);

final scheduleProvider =
    StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
  ref.watch(authTokenProvider);
  return ScheduleNotifier(
    ref.read(_fetchScheduleUseCaseProvider),
    ref.read(_markDoseUseCaseProvider),
    ref,
  );
});
