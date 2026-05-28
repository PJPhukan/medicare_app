import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/schedule_table.dart';

part 'schedule_dao.g.dart';

@DriftAccessor(tables: [ScheduleTable])
class ScheduleDao extends DatabaseAccessor<AppDatabase>
    with _$ScheduleDaoMixin {
  ScheduleDao(super.db);

  Future<void> upsert(ScheduleTableCompanion entry) =>
      into(scheduleTable).insertOnConflictUpdate(entry);

  Future<List<ScheduleRow>> getAll() => select(scheduleTable).get();

  Future<ScheduleRow?> getByDoseTimeId(String doseTimeId) =>
      (select(scheduleTable)
            ..where((t) => t.doseTimeId.equals(doseTimeId)))
          .getSingleOrNull();

  Future<void> updateStatus(String doseTimeId, String status) =>
      (update(scheduleTable)..where((t) => t.doseTimeId.equals(doseTimeId)))
          .write(ScheduleTableCompanion(status: Value(status)));

  Future<void> deleteByDoseTimeId(String doseTimeId) =>
      (delete(scheduleTable)..where((t) => t.doseTimeId.equals(doseTimeId)))
          .go();

  Future<void> clear() => delete(scheduleTable).go();
}
