import '../entities/pro_profile_entity.dart';
import '../entities/service_area_entity.dart';

abstract interface class ProProfileRepository {
  Future<ProProfileEntity> getMyProProfile();
  Future<ProProfileEntity> createProProfile(Map<String, dynamic> data);
  Future<ProProfileEntity> updateProProfile(Map<String, dynamic> data);
  Future<ServiceAreaEntity> addServiceArea({
    required String city,
    required String state,
    required String country,
    String? pincode,
  });
  Future<void> removeServiceArea(String serviceAreaId);
}
