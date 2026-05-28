import '../entities/patient_entity.dart';
import '../repositories/patients_repository.dart';

class FetchPatientsUseCase {
  const FetchPatientsUseCase(this._repo);

  final PatientsRepository _repo;

  Future<List<PatientEntity>> call() => _repo.getPatients();
}
