import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class FetchProfileUseCase {
  const FetchProfileUseCase(this._repo);

  final ProfileRepository _repo;

  Future<ProfileEntity> call() => _repo.getProfile();
}
