// // services/sync_metadata_service.dart
// class SyncMetadataService {
//   final AppDatabase _db;

//   SyncMetadataService(this._db);

//   Future<DateTime?> getLastSyncedAt(String entityName) async {
//     final row = await (_db.select(_db.syncMetadata)
//           ..where((t) => t.entityName.equals(entityName)))
//         .getSingleOrNull();

//     if (row?.lastSyncedAt == null) return null;
//     return DateTime.fromMillisecondsSinceEpoch(row!.lastSyncedAt!);
//   }

//   Future<void> setLastSyncedAt(String entityName, DateTime time) async {
//     await _db.into(_db.syncMetadata).insertOnConflictUpdate(
//           SyncMetadataCompanion.insert(
//             entityName: entityName,
//             lastSyncedAt: Value(time.millisecondsSinceEpoch),
//           ),
//         );
//   }
// }