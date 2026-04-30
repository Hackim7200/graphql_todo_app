// Starts and manages periodic sync runs for the whole app.
import 'dart:async';

import 'package:frontend/sync/sync_coordinator.dart';

class SyncScheduler {
  final SyncCoordinator _coordinator;
  Timer? _timer;

  SyncScheduler(this._coordinator);

  void start() {
    unawaited(_coordinator.syncOnce());
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => unawaited(_coordinator.syncOnce()),
    );
  }

  void stop() {
    _timer?.cancel();
  }

  Future<void> syncNow() => _coordinator.syncOnce();
}
