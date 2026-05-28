import '../entities/emergency_contact_entity.dart';

abstract interface class EmergencyRepository {
  Future<List<EmergencyContactEntity>> getContacts();
  Future<EmergencyContactEntity> addContact({
    required String name,
    required String phone,
    String? relationship,
    bool isPrimary,
  });
  Future<void> deleteContact(String id);
}
