// Coordinates one full sync run for all entities.
import 'package:frontend/database/database.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/sync/entities/pomodoro_syncer.dart';
import 'package:frontend/sync/entities/sync_entity.dart';
import 'package:frontend/sync/entities/todo_syncer.dart';
import 'package:frontend/sync/remote/pomodoro_remote.dart';
import 'package:frontend/sync/remote/todo_remote.dart';

class SyncCoordinator {
  final AppDatabase db;
  final List<SyncEntity> syncers;

  SyncCoordinator(this.db)
    : syncers = [
        TodoSyncer(db, const TodoRemote()),
        PomodoroSyncer(db, const PomodoroRemote()),
      ];

  Future<void> syncOnce() async { // this is the main sync file that does the sync
    for (final entity in syncers) {
      await _pushEntity(entity);
      await _pullEntity(entity);
    }
  }

  Future<void> _pushEntity(SyncEntity entity) async {
    //for each tables : todos, pomodoros, etc.
    //get the list of unsynced rows for that table
    //loop through the list of unsynced rows
    //push each row to the remote DB
    //mark as synced

    final pendingRows = await entity.getUnsyncedRowsFromLocalDB();

    for (final record in pendingRows) {
      try {
        await entity.pushUnsyncedRowsToRemoteDB(record);
        await entity.markAsSynced(record['id'].toString());
      } catch (e) {
        debugPrint('Push failed for ${entity.entityName}: $e');
      }
    }
  }

  Future<void> _pullEntity(SyncEntity entity) async {
    final lastSyncedAt = await entity.getLastSyncedAt();

    try {
      final remoteRecords = await entity.fetchRemoteChanges(lastSyncedAt);

      for (final record in remoteRecords) {
        await _applyWithLastWriteWins(entity, record);
      }

      await entity.setLastSyncedAt(DateTime.now().toUtc());
    } catch (e) {
      debugPrint('Pull failed for ${entity.entityName}: $e');
    }
  }

  Future<void> _applyWithLastWriteWins(
    SyncEntity entity,
    Map<String, dynamic> remote,
  ) async {
    final remoteId = remote['id']?.toString();
    if (remoteId == null) return;

    final local = await entity.getLocalRecord(remoteId);
    if (local == null) {
      await entity.applyRemoteRecord(remote);
      return;
    }

    final remoteUpdatedAt = _parseDateTime(remote['updatedAt']);
    final localUpdatedAt = _parseDateTime(local['updatedAt']);

    if (remoteUpdatedAt == null || localUpdatedAt == null) {
      await entity.applyRemoteRecord(remote);
      return;
    }

    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      await entity.applyRemoteRecord(remote);
    }
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
