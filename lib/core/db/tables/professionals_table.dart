import 'package:drift/drift.dart';

@DataClassName('ProfessionalRow')
class ProfessionalsTable extends Table {
  @override
  String get tableName => 'professionals';

  TextColumn get id => text()();
  TextColumn get categoryId => text()();
  TextColumn get rawJson => text()();
  IntColumn get updatedAt => integer()(); // ms since epoch

  @override
  Set<Column> get primaryKey => {id};
}
