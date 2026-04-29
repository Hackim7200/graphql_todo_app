import 'package:drift/drift.dart';
import 'package:frontend/database/database.dart';

class TodoService {
  TodoService(this._db);

  final AppDatabase _db;

  Stream<List<TodoTableData>> watchTodos() {
    return (_db.select(
      _db.todoTable,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  Future<List<TodoTableData>> getTodos() {
    return (_db.select(
      _db.todoTable,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  Future<int> addTodo(String title) {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Todo title cannot be empty.');
    }

    return _db
        .into(_db.todoTable)
        .insert(TodoTableCompanion.insert(title: trimmedTitle));
  }

  Future<int> updateTodoTitle({required int id, required String title}) {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Todo title cannot be empty.');
    }

    return (_db.update(_db.todoTable)..where((t) => t.id.equals(id))).write(
      TodoTableCompanion(title: Value(trimmedTitle)),
    );
  }

  Future<int> deleteTodo(int id) {
    return (_db.delete(_db.todoTable)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteAllTodos() {
    return _db.delete(_db.todoTable).go();
  }
}
