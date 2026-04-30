/// Defines the shared contract every syncable entity must implement.
abstract class Syncable {
  String get entityName;

  // push side
  Future<List<Map<String, dynamic>>> getPendingChanges();
  Future<void> pushRecord(Map<String, dynamic> record);
  Future<void> markAsSynced(String id);

  // pull side
  Future<DateTime?> getLastSyncedAt();
  Future<void> setLastSyncedAt(DateTime time);
  Future<List<Map<String, dynamic>>> fetchRemoteChanges(DateTime? since);

  // LWW
  Future<Map<String, dynamic>?> getLocalRecord(String id);
  Future<void> applyRemoteRecord(Map<String, dynamic> record);
}