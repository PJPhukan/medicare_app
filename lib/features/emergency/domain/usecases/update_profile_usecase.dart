import '../entities/emergency_profile_entity.dart';
import '../repositories/emergency_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repo);

  final EmergencyRepository _repo;

  Future<EmergencyProfileEntity> call({
    String? bloodGroup,
    List<String> allergies = const [],
    List<String> medications = const [],
    List<String> conditions = const [],
    String? notes,
  }) =>
      _repo.updateProfile(
        bloodGroup: bloodGroup,
        allergies: allergies,
        medications: medications,
        conditions: conditions,
        notes: notes,
      );
}
