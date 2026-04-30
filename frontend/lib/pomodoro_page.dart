import 'package:flutter/material.dart';
import 'package:frontend/database/database.dart';
import 'package:frontend/services/pomodoro_service.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({
    super.key,
    required this.todo,
    required this.pomodoroService,
  });

  final TodoTableData todo;
  final PomodoroService pomodoroService;

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  final TextEditingController _durationController = TextEditingController(
    text: '25',
  );

  Future<void> _addPomodoro() async {
    final duration = int.tryParse(_durationController.text.trim()) ?? 25;
    try {
      await widget.pomodoroService.addPomodoro(
        todoId: widget.todo.id,
        durationMinutes: duration,
      );
      _durationController.text = '25';
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add pomodoro: $e')));
    }
  }

  Future<void> _completePomodoro(String id) async {
    try {
      await widget.pomodoroService.completePomodoro(id: id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete pomodoro: $e')),
      );
    }
  }

  Future<void> _deletePomodoro(String id) async {
    try {
      await widget.pomodoroService.deletePomodoro(id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete pomodoro: $e')));
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pomodoros - ${widget.todo.title}')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addPomodoro(),
                    decoration: const InputDecoration(
                      hintText: 'Duration (minutes)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(onPressed: _addPomodoro, child: const Text('Add')),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PomodoroTableData>>(
              stream: widget.pomodoroService.watchPomodorosForTodo(
                widget.todo.id,
              ),
              builder: (context, snapshot) {
                final pomodoros = snapshot.data ?? const <PomodoroTableData>[];

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (pomodoros.isEmpty) {
                  return Center(
                    child: Text(
                      'No pomodoros yet. Add one above.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: pomodoros.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final pomodoro = pomodoros[index];
                    final status = pomodoro.completed ? 'Completed' : 'Running';
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: Text('${pomodoro.durationMinutes} minutes'),
                      subtitle: Text(
                        '$status - Start: ${pomodoro.startTime.toLocal().toString().split('.').first}',
                      ),
                      leading: IconButton(
                        icon: Icon(
                          pomodoro.completed
                              ? Icons.check_circle
                              : Icons.play_circle_fill,
                        ),
                        tooltip: pomodoro.completed
                            ? 'Already completed'
                            : 'Mark completed',
                        onPressed: pomodoro.completed
                            ? null
                            : () => _completePomodoro(pomodoro.id),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete',
                        onPressed: () => _deletePomodoro(pomodoro.id),
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
