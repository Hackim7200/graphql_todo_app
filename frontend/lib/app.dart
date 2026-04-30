import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:flutter/material.dart';
import 'package:frontend/database/database.dart';
import 'package:frontend/services/pomodoro_service.dart';
import 'package:frontend/services/todo_service.dart';
import 'todo_page.dart';

class MyApp extends StatelessWidget {
  final AppDatabase db;

  const MyApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
        builder: Authenticator.builder(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: TodoPage(
          todoService: TodoService(db),
          pomodoroService: PomodoroService(db),
        ),
      ),
    );
  }
}