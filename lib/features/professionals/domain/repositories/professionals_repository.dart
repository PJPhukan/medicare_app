import '../../data/models/location_models.dart';
import '../entities/professional_category_entity.dart';
import '../entities/professional_entity.dart';

abstract interface class ProfessionalsRepository {
  Future<List<ProfessionalCategoryEntity>> getCategories();

  Future<ProfessionalCategoryEntity> requestCategory(String name);

  Future<List<ProfessionalEntity>> listProfessionals({
    String? categoryId,
    String? search,
    bool? verified,
    int page,
    int limit,
  });

  Future<ProfessionalsLocationPage> listByLocation({
    String? pincode,
    String? areaId,
    String? categoryId,
    int page,
    int limit,
  });

  Future<ProfessionalEntity> getProfessional(String id);
}
