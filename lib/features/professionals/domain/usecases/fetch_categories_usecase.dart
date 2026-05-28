import '../entities/professional_category_entity.dart';
import '../repositories/professionals_repository.dart';

class FetchCategoriesUseCase {
  const FetchCategoriesUseCase(this._repo);

  final ProfessionalsRepository _repo;

  Future<List<ProfessionalCategoryEntity>> call() => _repo.getCategories();
}
