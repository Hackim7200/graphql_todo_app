/// Runs push + pull for one entity and resolves conflicts by latest update time.
import 'package:flutter/foundation.dart';
import 'package:frontend/sync/entities/syncable.dart';

class SyncEngine {
  final Syncable entity;

  SyncEngine(this.entity);

  Future<void> push() async {
    final pending = await entity.getPendingChanges();

    for (final record in pending) {
      try {
        await entity.pushRecord(record);
        await entity.markAsSynced(record['id'].toString());
      } catch (e) {
        debugPrint('Push failed for ${entity.entityName}: $e');
      }
    }
  }

  Future<void> pull() async {
    final lastSyncedAt = await entity.getLastSyncedAt();

    try {
      final remoteRecords = await entity.fetchRemoteChanges(lastSyncedAt);

      for (final record in remoteRecords) {
        await _applyWithLastWriteWins(record);
      }

      await entity.setLastSyncedAt(DateTime.now().toUtc());
    } catch (e) {
      debugPrint('Pull failed for ${entity.entityName}: $e');
    }
  }

  Future<void> _applyWithLastWriteWins(Map<String, dynamic> remote) async {
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