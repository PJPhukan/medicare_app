import '../entities/emergency_contact_entity.dart';
import '../repositories/emergency_repository.dart';

class UpdateContactUseCase {
  const UpdateContactUseCase(this._repo);

  final EmergencyRepository _repo;

  Future<EmergencyContactEntity> call({
    required String id,
    String? name,
    String? phone,
    String? relationship,
    int? priority,
  }) =>
      _repo.updateContact(
        id: id,
        name: name,
        phone: phone,
        relationship: relationship,
        priority: priority,
      );
}
