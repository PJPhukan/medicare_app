import '../../domain/entities/emergency_contact_entity.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../datasources/emergency_remote_datasource.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  const EmergencyRepositoryImpl(this._ds);

  final EmergencyRemoteDataSource _ds;

  @override
  Future<List<EmergencyContactEntity>> getContacts() async {
    final List<EmergencyContactEntity> list = await _ds.getContacts();
    return list;
  }

  @override
  Future<EmergencyContactEntity> addContact({
    required String name,
    required String phone,
    String? relationship,
    bool isPrimary = false,
  }) async {
    final EmergencyContactEntity contact = await _ds.addContact(
      name: name,
      phone: phone,
      relationship: relationship,
      isPrimary: isPrimary,
    );
    return contact;
  }

  @override
  Future<void> deleteContact(String id) => _ds.deleteContact(id);
}
