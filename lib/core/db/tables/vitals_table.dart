import 'package:drift/drift.dart';

@DataClassName('VitalRow')
class VitalsTable extends Table {
  @override
  String get tableName => 'vitals';

  TextColumn get id => text()();
  TextColumn get vitalConfigId => text()();
  IntColumn get measuredAt => integer()(); // ms since epoch
  TextColumn get rawJson => text()();
  IntColumn get updatedAt => integer()(); // ms since epoch

  @override
  Set<Column> get primaryKey => {id};
}
