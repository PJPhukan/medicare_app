import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/outbox_table.dart';
import 'tables/medicines_table.dart';
import 'tables/vitals_table.dart';
import 'tables/schedule_table.dart';
import 'tables/notifications_table.dart';
import 'tables/professionals_table.dart';
import 'tables/dose_logs_table.dart';

import 'daos/outbox_dao.dart';
import 'daos/medicines_dao.dart';
import 'daos/vitals_dao.dart';
import 'daos/schedule_dao.dart';
import 'daos/notifications_dao.dart';
import 'daos/professionals_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    OutboxTable,
    MedicinesTable,
    VitalsTable,
    ScheduleTable,
    NotificationsTable,
    ProfessionalsTable,
    DoseLogsTable,
  ],
  daos: [
    OutboxDao,
    MedicinesDao,
    VitalsDao,
    ScheduleDao,
    NotificationsDao,
    ProfessionalsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'medicare_offline.db'));
    return NativeDatabase.createInBackground(file);
  });
}

// ── Provider ──────────────────────────────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
