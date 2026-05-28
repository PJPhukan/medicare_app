import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/professionals_table.dart';

part 'professionals_dao.g.dart';

@DriftAccessor(tables: [ProfessionalsTable])
class ProfessionalsDao extends DatabaseAccessor<AppDatabase>
    with _$ProfessionalsDaoMixin {
  ProfessionalsDao(super.db);

  Future<void> upsert(ProfessionalsTableCompanion entry) =>
      into(professionalsTable).insertOnConflictUpdate(entry);

  Future<List<ProfessionalRow>> getAll() => select(professionalsTable).get();

  Future<List<ProfessionalRow>> getByCategoryId(String categoryId) =>
      (select(professionalsTable)
            ..where((t) => t.categoryId.equals(categoryId)))
          .get();

  Future<ProfessionalRow?> getById(String id) =>
      (select(professionalsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> deleteById(String id) =>
      (delete(professionalsTable)..where((t) => t.id.equals(id))).go();

  Future<void> clear() => delete(professionalsTable).go();
}
