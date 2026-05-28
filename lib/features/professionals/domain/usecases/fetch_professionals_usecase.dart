import '../entities/professional_entity.dart';
import '../repositories/professionals_repository.dart';

class FetchProfessionalsUseCase {
  const FetchProfessionalsUseCase(this._repo);

  final ProfessionalsRepository _repo;

  Future<List<ProfessionalEntity>> call({
    String? categoryId,
    String? search,
    bool? verified,
    int page = 1,
    int limit = 20,
  }) =>
      _repo.listProfessionals(
        categoryId: categoryId,
        search: search,
        verified: verified,
        page: page,
        limit: limit,
      );
}
