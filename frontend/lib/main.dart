import 'dart:io';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:frontend/database/database.dart';
import 'package:frontend/sync/sync_coordinator.dart';
import 'package:frontend/sync/sync_scheduler.dart';
import 'package:path_provider/path_provider.dart';

import 'amplifyconfiguration.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();
}

Future<void> bootstrap() async {
  try {
    final db = await _initDatabase();

    await _configureAmplify();
    final coordinator = SyncCoordinator(db);

    SyncScheduler(coordinator).start();

    runApp(MyApp(db: db));
  } on AmplifyException catch (e) {
    runApp(Text("Error configuring Amplify: ${e.message}"));
  }
}

Future<AppDatabase> _initDatabase() async {
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  final Directory dbDir = Directory('${appDocDir.path}/db');

  if (!await dbDir.exists()) {
    await dbDir.create();
  }

  return AppDatabase(dbDirectory: dbDir, sqliteFileName: 'app.db');
}

Future<void> _configureAmplify() async {
  await Amplify.addPlugins([AmplifyAuthCognito(), AmplifyAPI()]);
  await Amplify.configure(amplifyconfig);
  safePrint('Successfully configured Amplify');
}
