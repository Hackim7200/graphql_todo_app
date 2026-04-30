// Connects local pomodoro data with remote API calls for syncing.
import 'package:drift/drift.dart';
import 'package:frontend/database/database.dart';
import 'package:frontend/sync/remote/pomodoro_remote.dart';
import 'package:frontend/sync/entities/syncable_entity.dart';

class PomodoroSyncable implements SyncableEntity {
  PomodoroSyncable(this._db, this._remote);

  final AppDatabase _db;
  final PomodoroRemote _remote;
  DateTime? _lastSyncedAt;

  @override
  String get entityName => 'pomodoro';

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedRowsFromLocalDB() async {
    final rows = await (_db.select(
      _db.pomodoroTable,
    )..where((p) => p.syncStatus.equals('pending'))).get();
    return rows.map(_toMap).toList();
  }

  @override
  Future<void> pushUnsyncedRowsToRemoteDB(Map<String, dynamic> record) {
    return _remote.upsertPomodoro(record);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRemoteChanges(DateTime? since) {
    return _remote.getPomodorosSince(since);
  }

  @override
  Future<void> applyRemoteRecord(Map<String, dynamic> record) async {
    final id = _pomodoroIdFromRecord(record['id']);
    if (id == null) return;

    final todoId = _todoIdFromRecord(record['todoId']);
    if (todoId == null) return;

    final companion = PomodoroTableCompanion(
      id: Value(id),
      todoId: Value(todoId),
      durationMinutes: Value(_toInt(record['durationMinutes']) ?? 25),
      startTime: Value(_toDateTime(record['startTime']) ?? DateTime.now()),
      endTime: Value(_toDateTime(record['endTime'])),
      completed: Value((record['completed'] as bool?) ?? false),
      version: Value(_toInt(record['version']) ?? 0),
      updatedAt: Value(_toDateTime(record['updatedAt']) ?? DateTime.now()),
      createdAt: Value(_toDateTime(record['createdAt']) ?? DateTime.now()),
      isDeleted: Value((record['isDeleted'] as bool?) ?? false),
      syncStatus: const Value('synced'),
    );

    await _db.into(_db.pomodoroTable).insertOnConflictUpdate(companion);
  }

  @override
  Future<DateTime?> getLastSyncedAt() async => _lastSyncedAt;

  @override
  Future<void> setLastSyncedAt(DateTime time) async {
    _lastSyncedAt = time;
  }

  @override
  Future<Map<String, dynamic>?> getLocalRow(String id) async {
    if (id.isEmpty) return null;
    final row = await (_db.select(
      _db.pomodoroTable,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return _toMap(row);
  }

  @override
  Future<void> markAsSynced(String id) async {
    if (id.isEmpty) return;
    await (_db.update(_db.pomodoroTable)..where((p) => p.id.equals(id))).write(
      const PomodoroTableCompanion(syncStatus: Value('synced')),
    );
  }

  Map<String, dynamic> _toMap(PomodoroTableData row) {
    return <String, dynamic>{
      'id': row.id,
      'todoId': row.todoId,
      'durationMinutes': row.durationMinutes,
      'startTime': row.startTime.toUtc().toIso8601String(),
      'endTime': row.endTime?.toUtc().toIso8601String(),
      'completed': row.completed,
      'version': row.version,
      'updatedAt': row.updatedAt.toUtc().toIso8601String(),
      'createdAt': row.createdAt.toUtc().toIso8601String(),
      'isDeleted': row.isDeleted,
      'syncStatus': row.syncStatus,
    };
  }

  String? _pomodoroIdFromRecord(dynamic value) {
    if (value is String && value.isNotEmpty) return value;
    if (value is int) return value.toString();
    return null;
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
