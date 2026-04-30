import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:frontend/database/tables/pomodoro_table.dart';
import 'package:frontend/database/tables/todo_table.dart';
import 'package:path/path.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'database.g.dart';

// Drift database
@DriftDatabase(tables: [TodoTable, PomodoroTable])
class AppDatabase extends _$AppDatabase {
  final Directory dbDirectory;
  final String sqliteFileName;

  AppDatabase({required this.dbDirectory, required this.sqliteFileName})
    : super(_openConnection(dbDirectory, sqliteFileName));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(pomodoroTable);
      }
      if (from < 4) {
        await m.addColumn(pomodoroTable, pomodoroTable.version);
        await m.addColumn(pomodoroTable, pomodoroTable.updatedAt);
        await m.addColumn(pomodoroTable, pomodoroTable.createdAt);
        await m.addColumn(pomodoroTable, pomodoroTable.isDeleted);
        await m.addColumn(pomodoroTable, pomodoroTable.syncStatus);
      }
    },
  );
}

LazyDatabase _openConnection(Directory dbDirectory, String sqliteFileName) {
  return LazyDatabase(() async {
    if (!await dbDirectory.exists()) {
      await dbDirectory.create(recursive: true);
    }

    final file = File(join(dbDirectory.path, sqliteFileName));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        rawDb.execute('PRAGMA foreign_keys = ON');
        rawDb.execute('PRAGMA journal_mode = WAL');
        rawDb.execute('PRAGMA busy_timeout = 5000');
      },
    );
  });
}
