/// Builds entity syncers and runs them one by one.
import 'package:frontend/database/database.dart';
import 'package:frontend/sync/entities/pomodoro_syncer.dart';
import 'package:frontend/sync/entities/todo_syncer.dart';
import 'package:frontend/sync/remote/pomodoro_remote.dart';
import 'package:frontend/sync/remote/todo_remote.dart';
import 'package:frontend/sync/sync_engine.dart';
import 'package:frontend/sync/entities/syncable.dart';

class SyncOrchestrator {
  final AppDatabase db;
  final List<Syncable> syncerList;

  SyncOrchestrator(this.db)
      : syncerList = [
          TodoSyncer(db, const TodoRemote()),
          PomodoroSyncer(db, const PomodoroRemote()),
        ];

  Future<void> sync() async {
    for (final entity in syncerList) {
      final engine = SyncEngine(entity);
      await engine.push();
      await engine.pull();
    }
  }
}