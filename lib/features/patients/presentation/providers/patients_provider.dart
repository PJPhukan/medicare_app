import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/repositories/patients_repository.dart';
import 'patient_profiles_provider.dart' show patientsRepositoryProvider;

class PatientsState {
  const PatientsState({
    this.patients = const [],
    this.isLoading = false,
    this.error,
  });

  final List<PatientEntity> patients;
  final bool isLoading;
  final String? error;

  PatientsState copyWith({
    List<PatientEntity>? patients,
    bool? isLoading,
    String? error,
  }) =>
      PatientsState(
        patients: patients ?? this.patients,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class PatientsNotifier extends StateNotifier<PatientsState> {
  PatientsNotifier(this._repo) : super(const PatientsState()) {
    load();
  }

  final PatientsRepository _repo;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final patients = await _repo.getPatients();
      state = state.copyWith(patients: patients, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addPatient({
    required String name,
    String? phone,
    String? email,
    String? relation,
  }) async {
    AppLogger.i('Patient add → name:$name', tag: 'Patients');
    try {
      final added = await _repo.addPatient(
        name: name,
        phone: phone,
        email: email,
        relation: relation,
      );
      state = state.copyWith(patients: [...state.patients, added]);
      AppLogger.i('Patient added ✓ → id:${added.id}', tag: 'Patients');
      return true;
    } catch (e, s) {
      AppLogger.e('Patient add failed', tag: 'Patients', error: e, stack: s);
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Returns whether the removal actually succeeded — the caller must not
  /// report success on a rolled-back optimistic update.
  Future<bool> removePatient(String profileId) async {
    AppLogger.i('Patient remove → id:$profileId', tag: 'Patients');
    final prev = state.patients;
    state = state.copyWith(
      patients: prev.where((p) => p.id != profileId).toList(),
    );
    try {
      await _repo.removePatient(profileId);
      AppLogger.i('Patient removed ✓', tag: 'Patients');
      return true;
    } catch (e, s) {
      AppLogger.e('Patient remove failed', tag: 'Patients', error: e, stack: s);
      state = state.copyWith(patients: prev, error: e.toString());
      return false;
    }
  }
}

final patientsProvider =
    StateNotifierProvider<PatientsNotifier, PatientsState>((ref) {
  ref.watch(authTokenProvider);
  return PatientsNotifier(ref.read(patientsRepositoryProvider));
});
