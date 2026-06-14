import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../../../core/local_db/sync_queue.dart';
import '../../../../core/network/connectivity_monitor.dart';
import '../../data/datasources/vitals_remote_datasource.dart';
import '../../data/models/vital_config_model.dart';
import '../../data/models/vital_reading_model.dart';
import '../../data/repositories/vitals_repository_impl.dart';
import '../../domain/repositories/vitals_repository.dart';
import '../../domain/usecases/fetch_vital_configs_usecase.dart';
import '../../domain/usecases/fetch_vitals_usecase.dart';
import '../../domain/usecases/add_vital_reading_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/logger.dart';

class VitalsState {
  const VitalsState({
    this.configs = const [],
    this.readings = const [],
    this.isLoading = false,
    this.error,
    this.isOffline = false,
  });

  final List<VitalConfig> configs;
  final List<VitalReading> readings;
  final bool isLoading;
  final String? error;
  final bool isOffline;

  VitalsState copyWith({
    List<VitalConfig>? configs,
    List<VitalReading>? readings,
    bool? isLoading,
    String? error,
    bool? isOffline,
    bool clearError = false,
  }) =>
      VitalsState(
        configs: configs ?? this.configs,
        readings: readings ?? this.readings,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        isOffline: isOffline ?? this.isOffline,
      );
}

class VitalsNotifier extends StateNotifier<VitalsState> {
  VitalsNotifier(
    this._fetchConfigs,
    this._fetchVitals,
    this._addReading,
    this._ref,
  ) : super(const VitalsState()) {
    load();
    _ref.listen<bool>(isOnlineProvider, (prev, next) {
      if (next && (prev == false || prev == null)) load();
    });
  }

  final FetchVitalConfigsUseCase _fetchConfigs;
  final FetchVitalsUseCase _fetchVitals;
  final AddVitalReadingUseCase _addReading;
  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _fetchConfigs(),
        _fetchVitals(),
      ]);
      state = state.copyWith(
        configs: (results[0]).whereType<VitalConfig>().toList(),
        readings: (results[1]).whereType<VitalReading>().toList(),
        isLoading: false,
        isOffline: !_ref.read(isOnlineProvider),
      );
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addReading({
    required String vitalConfigId,
    required List<Map<String, dynamic>> values,
    String? measuredAt,
    String? notes,
  }) async {
    AppLogger.i('Vital reading add → configId:$vitalConfigId', tag: 'Vitals');
    try {
      final reading = await _addReading(
        vitalConfigId: vitalConfigId,
        values: values,
        measuredAt: measuredAt ?? DateTime.now().toIso8601String(),
        notes: notes,
      );
      state = state.copyWith(
        readings: [reading as VitalReading, ...state.readings],
      );
      AppLogger.i('Vital reading added ✓', tag: 'Vitals');
    } on UnsupportedError {
      AppLogger.i('Vital reading queued (offline)', tag: 'Vitals');
    } on Exception catch (e, s) {
      AppLogger.e('Vital reading failed', tag: 'Vitals', error: e, stack: s);
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final _vitalsDsProvider = Provider<VitalsRemoteDataSource>(
  (ref) => VitalsRemoteDataSource(ref.read(dioProvider)),
);

final vitalsRepositoryProvider = Provider<VitalsRepository>((ref) =>
    VitalsRepositoryImpl(
      ref.read(_vitalsDsProvider),
      ref.read(syncQueueProvider),
      () => ref.read(isOnlineProvider),
    ));

final _fetchVitalConfigsUseCaseProvider = Provider<FetchVitalConfigsUseCase>(
  (ref) => FetchVitalConfigsUseCase(ref.read(vitalsRepositoryProvider)),
);

final _fetchVitalsUseCaseProvider = Provider<FetchVitalsUseCase>(
  (ref) => FetchVitalsUseCase(ref.read(vitalsRepositoryProvider)),
);

final _addVitalReadingUseCaseProvider = Provider<AddVitalReadingUseCase>(
  (ref) => AddVitalReadingUseCase(ref.read(vitalsRepositoryProvider)),
);

final vitalsProvider =
    StateNotifierProvider<VitalsNotifier, VitalsState>((ref) {
  ref.watch(authTokenProvider);
  return VitalsNotifier(
    ref.read(_fetchVitalConfigsUseCaseProvider),
    ref.read(_fetchVitalsUseCaseProvider),
    ref.read(_addVitalReadingUseCaseProvider),
    ref,
  );
});
