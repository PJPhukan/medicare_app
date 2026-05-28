import '../entities/service_area_entity.dart';
import '../repositories/pro_profile_repository.dart';

class AddServiceAreaUseCase {
  const AddServiceAreaUseCase(this._repo);

  final ProProfileRepository _repo;

  Future<ServiceAreaEntity> call({
    required String city,
    required String state,
    required String country,
    String? pincode,
  }) =>
      _repo.addServiceArea(
        city: city,
        state: state,
        country: country,
        pincode: pincode,
      );
}
