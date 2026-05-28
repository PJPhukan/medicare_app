import 'package:drift/drift.dart';

@DataClassName('OutboxRow')
class OutboxTable extends Table {
  @override
  String get tableName => 'outbox';

  TextColumn get id => text()();
  TextColumn get feature => text()();
  TextColumn get action => text()();
  TextColumn get payload => text()(); // JSON string
  IntColumn get createdAt => integer()(); // ms since epoch
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
