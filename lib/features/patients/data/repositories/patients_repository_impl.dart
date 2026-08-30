import '../../domain/entities/patient_entity.dart';
import '../../domain/entities/patient_note_entity.dart';
import '../../domain/repositories/patients_repository.dart';
import '../datasources/patients_remote_datasource.dart';

class PatientsRepositoryImpl implements PatientsRepository {
  const PatientsRepositoryImpl(this._ds);

  final PatientsRemoteDataSource _ds;

  @override
  Future<List<PatientEntity>> getPatients() => _ds.getPatients();

  @override
  Future<PatientEntity> addPatient({
    required String name,
    String? phone,
    String? email,
    String? relation,
  }) =>
      _ds.addPatient(name: name, phone: phone, email: email, relation: relation);

  @override
  Future<void> removePatient(String profileId) => _ds.removePatient(profileId);

  @override
  Future<List<PatientNoteEntity>> getNotes(String profileId) =>
      _ds.getNotes(profileId);

  @override
  Future<PatientNoteEntity> addNote(String profileId, String note) =>
      _ds.addNote(profileId, note);
}
