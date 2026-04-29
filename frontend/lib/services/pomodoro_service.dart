import 'package:drift/drift.dart';
import 'package:frontend/database/database.dart';

class PomodoroService {
  PomodoroService(this._db);

  final AppDatabase _db;

  Stream<List<PomodoroTableData>> watchPomodorosForTodo(int todoId) {
    return (_db.select(_db.pomodoroTable)
          ..where((p) => p.todoId.equals(todoId))
          ..orderBy([(p) => OrderingTerm.desc(p.startTime)]))
        .watch();
  }

  Future<List<PomodoroTableData>> getPomodorosForTodo(int todoId) {
    return (_db.select(_db.pomodoroTable)
          ..where((p) => p.todoId.equals(todoId))
          ..orderBy([(p) => OrderingTerm.desc(p.startTime)]))
        .get();
  }

  Future<int> addPomodoro({
    required int todoId,
    int durationMinutes = 25,
    DateTime? startTime,
  }) {
    if (durationMinutes <= 0) {
      throw ArgumentError('Pomodoro duration must be greater than 0.');
    }

    return _db
        .into(_db.pomodoroTable)
        .insert(
          PomodoroTableCompanion.insert(
            todoId: todoId,
            durationMinutes: Value(durationMinutes),
            startTime: startTime ?? DateTime.now(),
          ),
        );
  }

  Future<int> completePomodoro({required int id, DateTime? endTime}) {
    return (_db.update(_db.pomodoroTable)..where((p) => p.id.equals(id))).write(
      PomodoroTableCompanion(
        completed: const Value(true),
        endTime: Value(endTime ?? DateTime.now()),
      ),
    );
  }

  Future<int> deletePomodoro(int id) {
    return (_db.delete(_db.pomodoroTable)..where((p) => p.id.equals(id))).go();
  }

  Future<int> deletePomodorosForTodo(int todoId) {
    return (_db.delete(
      _db.pomodoroTable,
    )..where((p) => p.todoId.equals(todoId))).go();
  }
}
