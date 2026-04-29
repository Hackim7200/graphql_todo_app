import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:flutter/material.dart';
import 'package:frontend/database/database.dart';
import 'package:frontend/pomodoro_page.dart';
import 'package:frontend/services/pomodoro_service.dart';
import 'package:frontend/services/todo_service.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({
    super.key,
    required this.todoService,
    required this.pomodoroService,
  });

  final TodoService todoService;
  final PomodoroService pomodoroService;

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _addTodo() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    try {
      await widget.todoService.addTodo(text);
      _controller.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add todo: $e')));
    }
  }

  Future<void> _deleteTodo(int id) async {
    try {
      await widget.todoService.deleteTodo(id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete todo: $e')));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: SignOutButton()),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addTodo(),
                    decoration: const InputDecoration(
                      hintText: 'What needs to be done?',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(onPressed: _addTodo, child: const Text('Add')),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<TodoTableData>>(
              stream: widget.todoService.watchTodos(),
              builder: (context, snapshot) {
                final todos = snapshot.data ?? const <TodoTableData>[];

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (todos.isEmpty) {
                  return Center(
                    child: Text(
                      'No todos yet. Add one above.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: todos.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: Text(todo.title),
                      subtitle: Text(
                        'Created: ${todo.createdAt.toLocal().toString().split('.').first}',
                      ),
                      leading: IconButton(
                        icon: const Icon(Icons.timer_outlined),
                        tooltip: 'Open pomodoros',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PomodoroPage(
                                todo: todo,
                                pomodoroService: widget.pomodoroService,
                              ),
                            ),
                          );
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete',
                        onPressed: () => _deleteTodo(todo.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
