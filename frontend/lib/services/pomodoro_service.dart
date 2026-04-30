import 'package:drift/drift.dart';
import 'package:frontend/database/database.dart';
import 'package:uuid/uuid.dart';

class PomodoroService {
  PomodoroService(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<PomodoroTableData>> watchPomodorosForTodo(String todoId) {
    return (_db.select(_db.pomodoroTable)
          ..where((p) => p.todoId.equals(todoId))
          ..orderBy([(p) => OrderingTerm.desc(p.startTime)]))
        .watch();
  }

  Future<List<PomodoroTableData>> getPomodorosForTodo(String todoId) {
    return (_db.select(_db.pomodoroTable)
          ..where((p) => p.todoId.equals(todoId))
          ..orderBy([(p) => OrderingTerm.desc(p.startTime)]))
        .get();
  }

  Future<String> addPomodoro({
    required String todoId,
    int durationMinutes = 25,
    DateTime? startTime,
  }) {
    if (durationMinutes <= 0) {
      throw ArgumentError('Pomodoro duration must be greater than 0.');
    }

    final id = _uuid.v4();
    return _db
        .into(_db.pomodoroTable)
        .insert(
          PomodoroTableCompanion.insert(
            id: id,
            todoId: todoId,
            durationMinutes: Value(durationMinutes),
            startTime: startTime ?? DateTime.now(),
          ),
        )
        .then((_) => id);
  }

  Future<int> completePomodoro({required String id, DateTime? endTime}) {
    return (_db.update(_db.pomodoroTable)..where((p) => p.id.equals(id))).write(
      PomodoroTableCompanion(
        completed: const Value(true),
        endTime: Value(endTime ?? DateTime.now()),
      ),
    );
  }

  Future<int> deletePomodoro(String id) {
    return (_db.delete(_db.pomodoroTable)..where((p) => p.id.equals(id))).go();
  }

  Future<int> deletePomodorosForTodo(String todoId) {
    return (_db.delete(
      _db.pomodoroTable,
    )..where((p) => p.todoId.equals(todoId))).go();
  }
}
