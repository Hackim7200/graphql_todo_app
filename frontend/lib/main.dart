import 'dart:io';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:frontend/database/database.dart';
import 'package:frontend/services/pomodoro_service.dart';
import 'package:frontend/services/todo_service.dart';
import 'package:path_provider/path_provider.dart';

import 'amplifyconfiguration.dart';
import 'todo_page.dart';

String sqliteFileName = 'driftExample';
late AppDatabase database;

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await initAppDatabase();
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
        home: TodoPage(
          todoService: TodoService(database),
          pomodoroService: PomodoroService(database),
        ),
      ),
    );
  }
}

Future<void> initAppDatabase() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  Directory dbDir = Directory('${appDocDir.path}/db');

  if (!await dbDir.exists()) {
    await dbDir.create();
    print("Folder created at ${dbDir.path}");
  } else {
    print("Folder already exists at ${dbDir.path}");
  }
  database = AppDatabase(
    dbDirectory: dbDir,
    sqliteFileName: 'app.db',
  );
}
