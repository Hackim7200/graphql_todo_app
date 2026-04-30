/// Defines the shared contract each entity sync implementation must follow.
abstract class SyncEntity {
  String get entityName;

  // push side
  Future<List<Map<String, dynamic>>> getUnsyncedRowsFromLocalDB();
  Future<void> pushUnsyncedRowsToRemoteDB(Map<String, dynamic> record);
  Future<void> markAsSynced(String id);

  // pull side
  Future<DateTime?> getLastSyncedAt();
  Future<void> setLastSyncedAt(DateTime time);
  Future<List<Map<String, dynamic>>> fetchRemoteChanges(DateTime? since);

  // LWW
  Future<Map<String, dynamic>?> getLocalRecord(String id);
  Future<void> applyRemoteRecord(Map<String, dynamic> record);
}
