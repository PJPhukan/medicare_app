import '../entities/emergency_contact_entity.dart';
import '../repositories/emergency_repository.dart';

class AddContactUseCase {
  const AddContactUseCase(this._repo);

  final EmergencyRepository _repo;

  Future<EmergencyContactEntity> call({
    required String name,
    required String phone,
    String? relationship,
    bool isPrimary = false,
    int priority = 0,
  }) =>
      _repo.addContact(
        name: name,
        phone: phone,
        relationship: relationship,
        isPrimary: isPrimary,
        priority: priority,
      );
}
