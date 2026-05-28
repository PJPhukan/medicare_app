import 'package:drift/drift.dart';

@DataClassName('ScheduleRow')
class ScheduleTable extends Table {
  @override
  String get tableName => 'schedule';

  TextColumn get doseTimeId => text()();
  TextColumn get status => text()();
  IntColumn get scheduledTime => integer()(); // ms since epoch
  TextColumn get rawJson => text()();
  IntColumn get updatedAt => integer()(); // ms since epoch

  @override
  Set<Column> get primaryKey => {doseTimeId};
}
