// Coordinates one full sync run for all entities.
import 'package:frontend/database/database.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/sync/entities/pomodoro_syncable.dart';
import 'package:frontend/sync/entities/syncable_entity.dart';
import 'package:frontend/sync/entities/todo_syncable.dart';
import 'package:frontend/sync/remote/pomodoro_remote.dart';
import 'package:frontend/sync/remote/todo_remote.dart';

class SyncCoordinator {
  final AppDatabase db;
  final List<SyncableEntity> syncers;

  SyncCoordinator(this.db)
    : syncers = [
        TodoSyncable(db, const TodoRemote()),
        PomodoroSyncable(db, const PomodoroRemote()),
      ];

  Future<void> syncOnce() async {
    // this is the main sync file that does the sync
    for (final entity in syncers) {
      await _pushEntity(entity);
      await _pullEntity(entity);
    }
  }

  Future<void> _pushEntity(SyncableEntity entity) async {
    //1. for each table/entity : todos, pomodoros, etc.
    //2.get the list of unsynced rows for that table
    //3.loop through the rows
    //4. push each row to the remote DB seperately (Very expensive approach but simple to implement)(batch push is more efficient)
    //5. mark as synced

    final pendingRows = await entity.getUnsyncedRowsFromLocalDB();

    for (final row in pendingRows) {
      try {
        await entity.pushUnsyncedRowsToRemoteDB(row);
        await entity.markAsSynced(
          row['id'].toString(),
        ); //  WHERE id = ? set syncStatus = 'synced'
      } catch (e) {
        debugPrint('Push failed for ${entity.entityName}: $e');
      }
    }
  }

  Future<void> _pullEntity(SyncableEntity entity) async {
    // this is null initially, but after the first sync, it will be set to the last synced time
    final lastSyncedAt = await entity.getLastSyncedAt();

    try {
      //returns list of all todo if null,
      //returns list of todos updated after the lastSyncedAt time if not null
      final remoteRows = await entity.fetchRemoteChanges(lastSyncedAt);

      for (final remoteRow in remoteRows) {
        await _applyWithLastWriteWins(entity, remoteRow);
      }

      await entity.setLastSyncedAt(DateTime.now().toUtc());
    } catch (e) {
      debugPrint('Pull failed for ${entity.entityName}: $e');
    }
  }

  Future<void> _applyWithLastWriteWins(
    SyncableEntity entity,
    Map<String, dynamic> remoteRow,
  ) async {
    final remoteId = remoteRow['id']?.toString();
    if (remoteId == null) return;
// since uuid is provided by client it should match ddb id
// if id is not found in local db it means ddb has new rows that are not synced yet
// so new rows are synced
    final localRow = await entity.getLocalRow(remoteId); 
    if (localRow == null) {
      await entity.applyRemoteRecord(remoteRow); // insert rows if id is not found in local db
      return;
    }
// check if remote updated at is after local updatedAt
//if so accept remote row and update local db
// the last updated wins and is accepted
// if local is more recent than remote then local is kept
    final remoteUpdatedAt = _parseDateTime(remoteRow['updatedAt']);
    final localUpdatedAt = _parseDateTime(localRow['updatedAt']);

    if (remoteUpdatedAt == null || localUpdatedAt == null) {
      await entity.applyRemoteRecord(remoteRow);
      return;
    }

    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      await entity.applyRemoteRecord(remoteRow);
    }
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
