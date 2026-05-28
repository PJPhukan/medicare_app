import '../../domain/entities/professional_category_entity.dart';
import '../../domain/entities/professional_entity.dart';
import '../../domain/repositories/professionals_repository.dart';
import '../datasources/professionals_remote_datasource.dart';

class ProfessionalsRepositoryImpl implements ProfessionalsRepository {
  const ProfessionalsRepositoryImpl(this._ds);

  final ProfessionalsRemoteDataSource _ds;

  @override
  Future<List<ProfessionalCategoryEntity>> getCategories() async {
    final List<ProfessionalCategoryEntity> list = await _ds.getCategories();
    return list;
  }

  @override
  Future<List<ProfessionalEntity>> listProfessionals({
    String? categoryId,
    String? search,
    bool? verified,
    int page = 1,
    int limit = 20,
  }) async {
    final List<ProfessionalEntity> list = await _ds.listProfessionals(
      categoryId: categoryId,
      search: search,
      verified: verified,
      page: page,
      limit: limit,
    );
    return list;
  }

  @override
  Future<ProfessionalEntity> getProfessional(String id) async {
    final ProfessionalEntity p = await _ds.getProfessional(id);
    return p;
  }
}
