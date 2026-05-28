import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/notifications_table.dart';

part 'notifications_dao.g.dart';

@DriftAccessor(tables: [NotificationsTable])
class NotificationsDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationsDaoMixin {
  NotificationsDao(super.db);

  Future<void> upsert(NotificationsTableCompanion entry) =>
      into(notificationsTable).insertOnConflictUpdate(entry);

  Future<List<NotificationRow>> getAll() =>
      (select(notificationsTable)
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();

  Future<List<NotificationRow>> getUnread() =>
      (select(notificationsTable)..where((t) => t.isRead.equals(false))).get();

  Future<void> markRead(String id) =>
      (update(notificationsTable)..where((t) => t.id.equals(id)))
          .write(const NotificationsTableCompanion(isRead: Value(true)));

  Future<void> markAllRead() =>
      update(notificationsTable).write(const NotificationsTableCompanion(isRead: Value(true)));

  Future<void> deleteById(String id) =>
      (delete(notificationsTable)..where((t) => t.id.equals(id))).go();

  Future<void> clear() => delete(notificationsTable).go();
}
