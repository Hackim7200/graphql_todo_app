import 'package:drift/drift.dart';
import 'package:frontend/database/database.dart';
import 'package:uuid/uuid.dart';

class TodoService {
  TodoService(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

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

  Future<String> addTodo(String title) {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Todo title cannot be empty.');
    }

    final id = _uuid.v4();
    return _db
        .into(_db.todoTable)
        .insert(
          TodoTableCompanion.insert(
            id: id,
            title: trimmedTitle,
          ),
        )
        .then((_) => id);
  }

  Future<int> updateTodoTitle({required String id, required String title}) {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Todo title cannot be empty.');
    }

    return (_db.update(_db.todoTable)..where((t) => t.id.equals(id))).write(
      TodoTableCompanion(title: Value(trimmedTitle)),
    );
  }

  Future<int> deleteTodo(String id) {
    return (_db.delete(_db.todoTable)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteAllTodos() {
    return _db.delete(_db.todoTable).go();
  }
}
