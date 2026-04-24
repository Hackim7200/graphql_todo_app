import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'amplifyconfiguration.dart';
import 'model/TodoModel.dart';
import 'services/todo_service.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await _configureAmplify();
    runApp(const MyApp());
  } on AmplifyException catch (e) {
    runApp(Text("Error configuring Amplify: ${e.message}"));
  }
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugins([AmplifyAuthCognito(), AmplifyAPI()]);
    await Amplify.configure(amplifyconfig);
    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
        builder: Authenticator.builder(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const TodoPage(),
      ),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TodoService _todoService = const TodoService();
  final TextEditingController _controller = TextEditingController();
  List<Todo> _todos = [];
  bool _loading = true;
  StreamSubscription<void>? _onTodoChangedSub;

  @override
  void initState() {
    super.initState();
    _subscribeToTodoUpdates();
    _loadTodos();
  }

  void _subscribeToTodoUpdates() {
    _onTodoChangedSub = _todoService.onTodoChanged().listen(
      (_) => _loadTodos(),
      onError: (Object e) => safePrint('Todo subscription error: $e'),
    );
  }

  Future<void> _loadTodos() async {
    setState(() => _loading = true);
    try {
      final todos = await _todoService.listTodos();
      setState(() {
        _todos = todos;
        _loading = false;
      });
    } on Exception catch (e) {
      safePrint('Error loading todos: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _addTodo() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    try {
      final newTodo = await _todoService.createTodo(text);
      setState(() => _todos.add(newTodo));
    } on Exception catch (e) {
      safePrint('Error creating todo: $e');
    }
  }

  Future<void> _toggleTodo(Todo todo) async {
    try {
      final updated = await _todoService.updateTodoCompletion(todo);
      setState(() {
        final i = _todos.indexWhere((t) => t.id == updated.id);
        if (i != -1) _todos[i] = updated;
      });
    } on Exception catch (e) {
      safePrint('Error updating todo: $e');
    }
  }

  Future<void> _deleteTodo(String id) async {
    setState(() => _todos.removeWhere((t) => t.id == id));

    try {
      await _todoService.deleteTodo(id);
    } on Exception catch (e) {
      safePrint('Error deleting todo: $e');
      await _loadTodos();
    }
  }

  @override
  void dispose() {
    _onTodoChangedSub?.cancel();
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
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _todos.isEmpty
                ? Center(
                    child: Text(
                      'No todos yet. Add one above.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _todos.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final todo = _todos[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        leading: Checkbox(
                          value: todo.isCompleted,
                          onChanged: (_) => _toggleTodo(todo),
                        ),
                        title: Text(
                          todo.title,
                          style: todo.isCompleted
                              ? const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete',
                          onPressed: () => _deleteTodo(todo.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
