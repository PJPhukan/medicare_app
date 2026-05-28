import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/medicines_table.dart';

part 'medicines_dao.g.dart';

@DriftAccessor(tables: [MedicinesTable])
class MedicinesDao extends DatabaseAccessor<AppDatabase>
    with _$MedicinesDaoMixin {
  MedicinesDao(super.db);

  Future<void> upsert(MedicinesTableCompanion entry) =>
      into(medicinesTable).insertOnConflictUpdate(entry);

  Future<List<MedicineRow>> getAll() => select(medicinesTable).get();

  Future<MedicineRow?> getById(String id) =>
      (select(medicinesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> deleteById(String id) =>
      (delete(medicinesTable)..where((t) => t.id.equals(id))).go();

  Future<void> clear() => delete(medicinesTable).go();
}
