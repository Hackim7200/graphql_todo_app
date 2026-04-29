// # todo-specific queries & mutations
// class TodoSyncer implements Syncable {
//   final TodoService _local;
//   final TodoRemote _remote;       // ← injected, not hardcoded

//   TodoSyncer(this._local, this._remote);

//   @override
//   Future<List<Map<String, dynamic>>> getPendingChanges() =>
//       _local.getPendingTodos();

//   @override
//   Future<void> pushRecord(Map<String, dynamic> record) =>
//       _remote.upsertTodo(record);   // api.post lives here

//   @override
//   Future<void> applyRemoteRecord(Map<String, dynamic> record) =>
//       _local.upsertTodo(record);
// }