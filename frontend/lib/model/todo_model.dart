// lib/models/todo.dart
class Todo {
  final String id;
  final String title;
  final bool isCompleted;

  const Todo({required this.id, required this.title, required this.isCompleted});

  factory Todo.fromJson(Map<String, dynamic> j) => Todo(
    id: j['id'] as String,
    title: j['title'] as String,
    isCompleted: j['isCompleted'] as bool,
  );
}