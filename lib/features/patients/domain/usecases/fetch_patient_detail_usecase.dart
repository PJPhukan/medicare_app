import '../entities/patient_detail_entity.dart';
import '../repositories/patients_repository.dart';

class FetchPatientDetailUseCase {
  const FetchPatientDetailUseCase(this._repo);

  final PatientsRepository _repo;

  Future<PatientDetailEntity> call(String patientId) =>
      _repo.getPatientDetail(patientId);
}
