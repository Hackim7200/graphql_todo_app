//  # connectivity watcher, triggers orchestrator
// dartclass SyncOrchestrator {
//   final List<Syncable> _entities;

//   SyncOrchestrator(this._entities);

//   Future<void> sync() async {
//     for (final entity in _entities) {
//       await _push(entity);
//       await _pull(entity);
//     }
//   }
// }