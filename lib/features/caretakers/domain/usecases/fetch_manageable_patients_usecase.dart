import '../entities/caretaker_entity.dart';
import '../repositories/caretakers_repository.dart';

class FetchManageablePatientsUseCase {
  const FetchManageablePatientsUseCase(this._repo);

  final CaretakersRepository _repo;

  Future<List<ManageablePatientEntity>> call() => _repo.getManageablePatients();
}
