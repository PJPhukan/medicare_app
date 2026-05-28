import 'package:drift/drift.dart';

@DataClassName('NotificationRow')
class NotificationsTable extends Table {
  @override
  String get tableName => 'notifications';

  TextColumn get id => text()();
  TextColumn get type => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get rawJson => text()();
  IntColumn get updatedAt => integer()(); // ms since epoch

  @override
  Set<Column> get primaryKey => {id};
}
