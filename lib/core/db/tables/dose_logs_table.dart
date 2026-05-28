import 'package:drift/drift.dart';

@DataClassName('DoseLogRow')
class DoseLogsTable extends Table {
  @override
  String get tableName => 'dose_logs';

  TextColumn get id => text()();
  TextColumn get doseTimeId => text()();
  TextColumn get status => text()();
  TextColumn get takenAt => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()(); // ms since epoch

  @override
  Set<Column> get primaryKey => {id};
}
