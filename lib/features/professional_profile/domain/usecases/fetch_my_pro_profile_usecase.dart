import '../entities/pro_profile_entity.dart';
import '../repositories/pro_profile_repository.dart';

class FetchMyProProfileUseCase {
  const FetchMyProProfileUseCase(this._repo);

  final ProProfileRepository _repo;

  Future<ProProfileEntity> call() => _repo.getMyProProfile();
}
