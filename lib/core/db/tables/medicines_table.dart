import 'package:drift/drift.dart';

@DataClassName('MedicineRow')
class MedicinesTable extends Table {
  @override
  String get tableName => 'medicines';

  TextColumn get id => text()();
  TextColumn get rawJson => text()();
  IntColumn get updatedAt => integer()(); // ms since epoch

  @override
  Set<Column> get primaryKey => {id};
}
