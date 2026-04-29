import 'package:drift/drift.dart';
import 'package:frontend/database/tables/todo_table.dart';

class PomodoroTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get todoId =>
      integer().references(TodoTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get durationMinutes => integer().withDefault(const Constant(25))();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}
