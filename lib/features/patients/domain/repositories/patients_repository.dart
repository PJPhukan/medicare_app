import '../entities/patient_entity.dart';
import '../entities/patient_note_entity.dart';

abstract interface class PatientsRepository {
  Future<List<PatientEntity>> getPatients();

  Future<PatientEntity> addPatient({
    required String name,
    String? phone,
    String? email,
    String? relation,
  });

  Future<void> removePatient(String profileId);

  Future<List<PatientNoteEntity>> getNotes(String profileId);

  Future<PatientNoteEntity> addNote(String profileId, String note);
}
