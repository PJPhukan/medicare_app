import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/vitals_table.dart';

part 'vitals_dao.g.dart';

@DriftAccessor(tables: [VitalsTable])
class VitalsDao extends DatabaseAccessor<AppDatabase> with _$VitalsDaoMixin {
  VitalsDao(super.db);

  Future<void> upsert(VitalsTableCompanion entry) =>
      into(vitalsTable).insertOnConflictUpdate(entry);

  Future<List<VitalRow>> getAll() => select(vitalsTable).get();

  Future<List<VitalRow>> getByConfigId(String configId) =>
      (select(vitalsTable)
            ..where((t) => t.vitalConfigId.equals(configId))
            ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)]))
          .get();

  Future<void> deleteById(String id) =>
      (delete(vitalsTable)..where((t) => t.id.equals(id))).go();

  Future<void> clear() => delete(vitalsTable).go();
}
