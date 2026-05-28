import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/outbox_table.dart';

part 'outbox_dao.g.dart';

@DriftAccessor(tables: [OutboxTable])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.db);

  Future<void> enqueue(OutboxTableCompanion entry) =>
      into(outboxTable).insert(entry);

  Future<List<OutboxRow>> getAll() => select(outboxTable).get();

  Future<void> deleteById(String id) =>
      (delete(outboxTable)..where((t) => t.id.equals(id))).go();

  Future<void> incrementRetry(String id) async {
    final row = await (select(outboxTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return;
    await (update(outboxTable)..where((t) => t.id.equals(id)))
        .write(OutboxTableCompanion(retryCount: Value(row.retryCount + 1)));
  }

  Future<void> clear() => delete(outboxTable).go();
}
