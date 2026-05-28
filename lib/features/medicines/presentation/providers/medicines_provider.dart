import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/client.dart';
import '../../../../core/local_db/sync_queue.dart';
import '../../../../core/network/connectivity_monitor.dart';
import '../../data/datasources/medicines_remote_datasource.dart';
import '../../data/models/medicine_model.dart';
import '../../data/repositories/medicines_repository_impl.dart';
import '../../domain/repositories/medicines_repository.dart';
import '../../domain/usecases/fetch_medicines_usecase.dart';
import '../../domain/usecases/delete_medicine_usecase.dart';
import '../../domain/usecases/add_medicine_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/logger.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class MedicinesState {
  const MedicinesState({
    this.medicines = const [],
    this.isLoading = false,
    this.error,
    this.isOffline = false,
  });

  final List<UserMedicine> medicines;
  final bool isLoading;
  final String? error;
  final bool isOffline;

  MedicinesState copyWith({
    List<UserMedicine>? medicines,
    bool? isLoading,
    String? error,
    bool? isOffline,
    bool clearError = false,
  }) =>
      MedicinesState(
        medicines: medicines ?? this.medicines,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        isOffline: isOffline ?? this.isOffline,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class MedicinesNotifier extends StateNotifier<MedicinesState> {
  MedicinesNotifier(
    this._fetchMedicines,
    this._deleteMedicine,
    this._addMedicine,
    this._ref,
  ) : super(const MedicinesState()) {
    load();
    _ref.listen<bool>(isOnlineProvider, (prev, next) {
      if (next && (prev == false || prev == null)) load();
    });
  }

  final FetchMedicinesUseCase _fetchMedicines;
  final DeleteMedicineUseCase _deleteMedicine;
  final AddMedicineUseCase _addMedicine;
  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final entities = await _fetchMedicines();
      state = state.copyWith(
        medicines: entities.whereType<UserMedicine>().toList(),
        isLoading: false,
        isOffline: !_ref.read(isOnlineProvider),
      );
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteMedicine(String id) async {
    AppLogger.i('Medicine delete → id:$id', tag: 'Medicine');
    state = state.copyWith(
      medicines: state.medicines.where((m) => m.id != id).toList(),
    );
    try {
      await _deleteMedicine(id);
      AppLogger.i('Medicine deleted ✓', tag: 'Medicine');
    } on Exception catch (e, s) {
      AppLogger.e('Medicine delete failed', tag: 'Medicine', error: e, stack: s);
      await load();
      rethrow;
    }
  }

  Future<void> addMedicine({
    required String medicineId,
    String? customName,
    String? patientProfileId,
  }) async {
    AppLogger.i('Medicine add → catalogId:$medicineId', tag: 'Medicine');
    try {
      await _addMedicine(
        medicineId: medicineId,
        customName: customName,
        patientProfileId: patientProfileId,
      );
      await load();
      AppLogger.i('Medicine added ✓', tag: 'Medicine');
    } on Exception catch (e, s) {
      AppLogger.e('Medicine add failed', tag: 'Medicine', error: e, stack: s);
      rethrow;
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final _medicinesDsProvider = Provider<MedicinesRemoteDataSource>(
  (ref) => MedicinesRemoteDataSource(ref.read(dioProvider)),
);

final medicinesRepositoryProvider = Provider<MedicinesRepository>((ref) =>
    MedicinesRepositoryImpl(
      ref.read(_medicinesDsProvider),
      ref.read(syncQueueProvider),
      () => ref.read(isOnlineProvider),
    ));

final _fetchMedicinesUseCaseProvider = Provider<FetchMedicinesUseCase>(
  (ref) => FetchMedicinesUseCase(ref.read(medicinesRepositoryProvider)),
);

final _deleteMedicineUseCaseProvider = Provider<DeleteMedicineUseCase>(
  (ref) => DeleteMedicineUseCase(ref.read(medicinesRepositoryProvider)),
);

final _addMedicineUseCaseProvider = Provider<AddMedicineUseCase>(
  (ref) => AddMedicineUseCase(ref.read(medicinesRepositoryProvider)),
);

final medicinesProvider =
    StateNotifierProvider<MedicinesNotifier, MedicinesState>((ref) {
  ref.watch(authTokenProvider);
  return MedicinesNotifier(
    ref.read(_fetchMedicinesUseCaseProvider),
    ref.read(_deleteMedicineUseCaseProvider),
    ref.read(_addMedicineUseCaseProvider),
    ref,
  );
});
