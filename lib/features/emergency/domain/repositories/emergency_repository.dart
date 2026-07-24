import '../entities/emergency_contact_entity.dart';
import '../entities/emergency_profile_entity.dart';

abstract interface class EmergencyRepository {
  /// Null when no emergency profile has been created yet.
  Future<EmergencyProfileEntity?> getProfile();
  Future<List<EmergencyContactEntity>> getContacts();
  Future<EmergencyContactEntity> addContact({
    required String name,
    required String phone,
    String? relationship,
    bool isPrimary,
    int priority,
  });
  Future<EmergencyContactEntity> updateContact({
    required String id,
    String? name,
    String? phone,
    String? relationship,
    int? priority,
  });
  Future<void> deleteContact(String id);

  /// Logs the SOS server-side (audit + FCM fan-out to contacts who are
  /// registered users). Returns the SosLog id, or null when offline.
  Future<String?> triggerSos({
    double? latitude,
    double? longitude,
    String? locationName,
  });

  Future<void> cancelSos(String sosId);
}
