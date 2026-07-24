import '../entities/emergency_profile_entity.dart';
import '../repositories/emergency_repository.dart';

class FetchProfileUseCase {
  const FetchProfileUseCase(this._repo);

  final EmergencyRepository _repo;

  Future<EmergencyProfileEntity?> call() => _repo.getProfile();
}
