import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UploadAvatarUseCase {
  const UploadAvatarUseCase(this._repo);

  final ProfileRepository _repo;

  Future<ProfileEntity> call(String filePath) =>
      _repo.uploadAvatar(filePath);
}
