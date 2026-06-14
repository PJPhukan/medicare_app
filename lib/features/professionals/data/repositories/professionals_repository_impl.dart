import '../../data/models/location_models.dart';
import '../../domain/entities/professional_category_entity.dart';
import '../../domain/entities/professional_entity.dart';
import '../../domain/repositories/professionals_repository.dart';
import '../datasources/professionals_remote_datasource.dart';

class ProfessionalsRepositoryImpl implements ProfessionalsRepository {
  const ProfessionalsRepositoryImpl(this._ds);

  final ProfessionalsRemoteDataSource _ds;

  @override
  Future<List<ProfessionalCategoryEntity>> getCategories() => _ds.getCategories();

  @override
  Future<ProfessionalCategoryEntity> requestCategory(String name) => _ds.requestCategory(name);

  @override
  Future<List<ProfessionalEntity>> listProfessionals({
    String? categoryId,
    String? search,
    bool? verified,
    int page = 1,
    int limit = 20,
  }) => _ds.listProfessionals(
        categoryId: categoryId,
        search: search,
        verified: verified,
        page: page,
        limit: limit,
      );

  @override
  Future<ProfessionalsLocationPage> listByLocation({
    String? pincode,
    String? areaId,
    String? categoryId,
    int page = 1,
    int limit = 10,
  }) => _ds.listByLocation(
        pincode: pincode,
        areaId: areaId,
        categoryId: categoryId,
        page: page,
        limit: limit,
      );

  @override
  Future<ProfessionalEntity> getProfessional(String id) => _ds.getProfessional(id);
}
