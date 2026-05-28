import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repo);

  final ProfileRepository _repo;

  Future<ProfileEntity> call(Map<String, dynamic> data) =>
      _repo.updateProfile(data);
}
