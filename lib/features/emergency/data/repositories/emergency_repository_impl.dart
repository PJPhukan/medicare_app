import '../../domain/entities/emergency_contact_entity.dart';
import '../../domain/entities/emergency_profile_entity.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../datasources/emergency_remote_datasource.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  const EmergencyRepositoryImpl(this._ds);

  final EmergencyRemoteDataSource _ds;

  @override
  Future<EmergencyProfileEntity?> getProfile() => _ds.getProfile();

  @override
  Future<EmergencyProfileEntity> updateProfile({
    String? bloodGroup,
    List<String> allergies = const [],
    List<String> medications = const [],
    List<String> conditions = const [],
    String? notes,
  }) =>
      _ds.updateProfile(
        bloodGroup: bloodGroup,
        allergies: allergies,
        medications: medications,
        conditions: conditions,
        notes: notes,
      );

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
    int priority = 0,
  }) async {
    final EmergencyContactEntity contact = await _ds.addContact(
      name: name,
      phone: phone,
      relation: relationship,
      priority: priority,
    );
    return contact;
  }

  @override
  Future<EmergencyContactEntity> updateContact({
    required String id,
    String? name,
    String? phone,
    String? relationship,
    int? priority,
  }) =>
      _ds.updateContact(
        id: id,
        name: name,
        phone: phone,
        relation: relationship,
        priority: priority,
      );

  @override
  Future<void> deleteContact(String id) => _ds.deleteContact(id);

  @override
  Future<String?> triggerSos({
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    final data = await _ds.triggerSos(
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
    );
    return data['id'] as String?;
  }

  @override
  Future<void> cancelSos(String sosId) => _ds.cancelSos(sosId);
}
