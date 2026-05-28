import '../entities/professional_entity.dart';
import '../repositories/professionals_repository.dart';

class FetchProfessionalDetailUseCase {
  const FetchProfessionalDetailUseCase(this._repo);

  final ProfessionalsRepository _repo;

  Future<ProfessionalEntity> call(String id) => _repo.getProfessional(id);
}
