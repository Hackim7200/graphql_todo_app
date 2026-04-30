// Connects local todo data with remote API calls for syncing.
import 'package:drift/drift.dart';
import 'package:frontend/database/database.dart';
import 'package:frontend/sync/remote/todo_remote.dart';
import 'package:frontend/sync/entities/syncable_entity.dart';

class TodoSyncable implements SyncableEntity {
  TodoSyncable(this._db, this._remote);

  final AppDatabase _db;
  final TodoRemote _remote;
  DateTime? _lastSyncedAt;

  @override
  String get entityName => 'todo';

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedRowsFromLocalDB() async {
    //get all rows from local DB where syncStatus is 'pending'
    //return the rows as a list of maps
    final rows = await (_db.select(
      _db.todoTable,
    )..where((t) => t.syncStatus.equals('pending'))).get();
    return rows.map(_toMap).toList();
  }

  @override
  Future<void> pushUnsyncedRowsToRemoteDB(Map<String, dynamic> record) {
    return _remote.upsertTodo(record);
  }

  @override
  Future<void> markAsSynced(String id) async {
    if (id.isEmpty) return;

    await (_db.update(_db.todoTable)..where((t) => t.id.equals(id))).write(
      const TodoTableCompanion(syncStatus: Value('synced')),
    );
  }

  @override
  Future<DateTime?> getLastSyncedAt() async => _lastSyncedAt;

  @override
  Future<void> setLastSyncedAt(DateTime time) async {
    _lastSyncedAt = time;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRemoteChanges(DateTime? since) {
    return _remote.getTodosSince(since);
  }

  @override
  Future<Map<String, dynamic>?> getLocalRow(String id) async {
    if (id.isEmpty) return null;
    final row = await (_db.select(
      _db.todoTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return _toMap(row);
  }

  @override
  Future<void> applyRemoteRecord(Map<String, dynamic> record) async {
    final id = _todoIdFromRecord(record['id']);
    if (id == null) return;

    final companion = TodoTableCompanion(
      id: Value(id),
      title: Value((record['title'] as String?) ?? ''),
      completed: Value((record['completed'] as bool?) ?? false),
      version: Value(_toInt(record['version']) ?? 0),
      updatedAt: Value(_toDateTime(record['updatedAt']) ?? DateTime.now()),
      createdAt: Value(_toDateTime(record['createdAt']) ?? DateTime.now()),
      isDeleted: Value((record['isDeleted'] as bool?) ?? false),
      syncStatus: const Value('synced'),
    );
    await _db.into(_db.todoTable).insertOnConflictUpdate(companion);
  }

  Map<String, dynamic> _toMap(TodoTableData row) {
    return <String, dynamic>{
      'id': row.id,
      'title': row.title,
      'completed': row.completed,
      'version': row.version,
      'updatedAt': row.updatedAt.toUtc().toIso8601String(),
      'createdAt': row.createdAt.toUtc().toIso8601String(),
      'isDeleted': row.isDeleted,
      'syncStatus': row.syncStatus,
    };
  }

  String? _todoIdFromRecord(dynamic value) {
    if (value is String && value.isNotEmpty) return value;
    if (value is int) return value.toString();
    return null;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  DateTime? _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
