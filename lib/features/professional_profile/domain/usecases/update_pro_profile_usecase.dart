import '../entities/pro_profile_entity.dart';
import '../repositories/pro_profile_repository.dart';

class UpdateProProfileUseCase {
  const UpdateProProfileUseCase(this._repo);

  final ProProfileRepository _repo;

  Future<ProProfileEntity> call(Map<String, dynamic> data) =>
      _repo.updateProProfile(data);
}
