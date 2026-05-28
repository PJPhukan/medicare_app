import '../entities/emergency_contact_entity.dart';
import '../repositories/emergency_repository.dart';

class FetchContactsUseCase {
  const FetchContactsUseCase(this._repo);

  final EmergencyRepository _repo;

  Future<List<EmergencyContactEntity>> call() => _repo.getContacts();
}
