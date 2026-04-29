// // # abstract interface every entity implements
// abstract class Syncable {
//   String get entityName;

//   Future<List<Map<String, dynamic>>> getPendingChanges();
//   Future<void> pushRecord(Map<String, dynamic> record);
//   Future<void> applyRemoteRecord(Map<String, dynamic> record);
//   Future<DateTime?> getLastSyncedAt();
//   Future<void> setLastSyncedAt(DateTime time);
// }