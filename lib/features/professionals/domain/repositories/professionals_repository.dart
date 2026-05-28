import '../entities/professional_category_entity.dart';
import '../entities/professional_entity.dart';

abstract interface class ProfessionalsRepository {
  Future<List<ProfessionalCategoryEntity>> getCategories();
  Future<List<ProfessionalEntity>> listProfessionals({
    String? categoryId,
    String? search,
    bool? verified,
    int page,
    int limit,
  });
  Future<ProfessionalEntity> getProfessional(String id);
}
