import '../repositories/pro_profile_repository.dart';

class RemoveServiceAreaUseCase {
  const RemoveServiceAreaUseCase(this._repo);

  final ProProfileRepository _repo;

  Future<void> call(String serviceAreaId) =>
      _repo.removeServiceArea(serviceAreaId);
}
