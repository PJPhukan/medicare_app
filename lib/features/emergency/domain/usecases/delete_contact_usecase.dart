import '../repositories/emergency_repository.dart';

class DeleteContactUseCase {
  const DeleteContactUseCase(this._repo);

  final EmergencyRepository _repo;

  Future<void> call(String id) => _repo.deleteContact(id);
}
