import '../../domain/entities/pro_profile_entity.dart';
import '../../domain/entities/service_area_entity.dart';
import '../../domain/repositories/pro_profile_repository.dart';
import '../datasources/pro_profile_remote_datasource.dart';

class ProProfileRepositoryImpl implements ProProfileRepository {
  const ProProfileRepositoryImpl(this._ds);

  final ProProfileRemoteDataSource _ds;

  @override
  Future<ProProfileEntity> getMyProProfile() async {
    final ProProfileEntity profile = await _ds.getMyProProfile();
    return profile;
  }

  @override
  Future<ProProfileEntity> createProProfile(Map<String, dynamic> data) async {
    final ProProfileEntity profile = await _ds.createProProfile(data);
    return profile;
  }

  @override
  Future<ProProfileEntity> updateProProfile(Map<String, dynamic> data) async {
    final ProProfileEntity profile = await _ds.updateProProfile(data);
    return profile;
  }

  @override
  Future<ServiceAreaEntity> addServiceArea({
    required String city,
    required String state,
    required String country,
    String? pincode,
  }) async {
    final ServiceAreaEntity area = await _ds.addServiceArea(
      city: city,
      state: state,
      country: country,
      pincode: pincode,
    );
    return area;
  }

  @override
  Future<void> removeServiceArea(String serviceAreaId) =>
      _ds.removeServiceArea(serviceAreaId);

  @override
  Future<void> requestNewArea({
    required String name,
    required String pincodes,
    required String state,
    required String district,
  }) =>
      _ds.requestNewArea(
        name: name,
        pincodes: pincodes,
        state: state,
        district: district,
      );
}
