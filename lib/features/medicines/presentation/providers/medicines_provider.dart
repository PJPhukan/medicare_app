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
// Dose schedules are owned by the schedule feature — the add-medicine flow
// goes through its notifier so the local alarms are registered too.
import '../../../schedule/presentation/providers/reminders_provider.dart';
import '../../../schedule/data/models/reminder_schedule_model.dart'
    show parseDoseAmount;
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
    if (!mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final entities = await _fetchMedicines();
      if (!mounted) return;
      state = state.copyWith(
        medicines: entities.whereType<UserMedicine>().toList(),
        isLoading: false,
        isOffline: !_ref.read(isOnlineProvider),
      );
    } catch (e, s) {
      AppLogger.e('Medicines load failed', tag: 'Medicines', error: e, stack: s);
      if (!mounted) return;
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

  /// Changes who a medicine is for and refreshes the cabinet.
  Future<void> reassignMedicine(String id, String? patientProfileId) async {
    AppLogger.i('Medicine reassign → id:$id profile:$patientProfileId',
        tag: 'Medicine');
    await _ref
        .read(medicinesRepositoryProvider)
        .reassignMedicine(id, patientProfileId: patientProfileId);
    await load();
  }

  /// Creates a shared bottle — one master plus a member per patient profile.
  ///
  /// A different endpoint from a personal add, so it does not share
  /// [addMedicine]'s schedule/stock follow-ups: stock lives on the master and
  /// each member gets its own schedule later.
  Future<void> addSharedMedicine({
    String? medicineId,
    String? productId,
    required List<String> memberPatientProfileIds,
  }) async {
    AppLogger.i(
      'Shared medicine add → members:${memberPatientProfileIds.length}',
      tag: 'Medicine',
    );
    await _ref.read(medicinesRepositoryProvider).addSharedMedicine(
          medicineId: medicineId,
          productId: productId,
          memberPatientProfileIds: memberPatientProfileIds,
        );
    await load();
  }

  /// Adds a cabinet entry and, in the same flow, the schedule and stock the
  /// add wizard collected. The medicine is created first because both
  /// follow-ups are keyed on its id; if one of them fails the medicine still
  /// exists, so the failure is returned as a warning rather than thrown —
  /// throwing would tell the user nothing was saved when something was.
  ///
  /// Returns the warnings to surface, empty when everything landed.
  Future<List<String>> addMedicine({
    String? medicineId,
    String? productId,
    String? customName,
    String? patientProfileId,
    List<String> doseTimes = const [],
    String scheduleType = 'DAILY',
    bool isPrn = false,
    String doseAmount = '',
    String foodTiming = 'WITH',
    int? stockQuantity,
    String? expiryDate,
    DateTime? endDate,
  }) async {
    AppLogger.i(
      'Medicine add → medicineId:$medicineId productId:$productId '
      'times:${doseTimes.length} prn:$isPrn stock:$stockQuantity',
      tag: 'Medicine',
    );
    final warnings = <String>[];
    try {
      final created = await _addMedicine(
        medicineId: medicineId,
        productId: productId,
        customName: customName,
        patientProfileId: patientProfileId,
      );

      if (doseTimes.isNotEmpty || isPrn) {
        try {
          final dose = parseDoseAmount(doseAmount);
          await _ref.read(remindersProvider.notifier).createSchedule(
                userMedicineId: created.id,
                medicineName: created.displayName,
                times: doseTimes,
                quantity: dose.quantity ?? 1,
                unit: dose.unit ?? '',
                foodTiming: foodTiming,
                scheduleType: isPrn ? 'PRN' : scheduleType,
                endDate: endDate,
              );
        } catch (e, s) {
          AppLogger.e('Medicine schedule create failed',
              tag: 'Medicine', error: e, stack: s);
          warnings.add('Reminders could not be saved — add them from Schedule.');
        }
      }

      if (stockQuantity != null && stockQuantity > 0) {
        try {
          await _ref.read(medicinesRepositoryProvider).addStock(
                created.id,
                quantity: stockQuantity,
                expiryDate: expiryDate,
              );
        } catch (e, s) {
          AppLogger.e('Medicine stock create failed',
              tag: 'Medicine', error: e, stack: s);
          warnings.add('Stock could not be saved — add it from the medicine.');
        }
      }

      await load();
      AppLogger.i('Medicine added ✓ → id:${created.id}', tag: 'Medicine');
      return warnings;
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
