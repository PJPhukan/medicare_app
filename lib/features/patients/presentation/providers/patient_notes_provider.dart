import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/patient_note_entity.dart';
import '../../domain/repositories/patients_repository.dart';
import 'patient_profiles_provider.dart' show patientsRepositoryProvider;

class PatientNotesState {
  const PatientNotesState({
    this.notes = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  final List<PatientNoteEntity> notes;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  PatientNotesState copyWith({
    List<PatientNoteEntity>? notes,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) =>
      PatientNotesState(
        notes: notes ?? this.notes,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        error: error,
      );
}

class PatientNotesNotifier extends StateNotifier<PatientNotesState> {
  PatientNotesNotifier(this._repo, this._profileId)
      : super(const PatientNotesState()) {
    load();
  }

  final PatientsRepository _repo;
  final String _profileId;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final notes = await _repo.getNotes(_profileId);
      state = state.copyWith(notes: notes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addNote(String note) async {
    AppLogger.i('Patient note add → profileId:$_profileId', tag: 'Patients');
    state = state.copyWith(isSaving: true, error: null);
    try {
      final created = await _repo.addNote(_profileId, note);
      state = state.copyWith(
        notes: [created, ...state.notes],
        isSaving: false,
      );
      return true;
    } catch (e, s) {
      AppLogger.e('Patient note add failed', tag: 'Patients', error: e, stack: s);
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}

final patientNotesProvider = StateNotifierProvider.family<PatientNotesNotifier,
    PatientNotesState, String>((ref, profileId) {
  return PatientNotesNotifier(ref.read(patientsRepositoryProvider), profileId);
});
