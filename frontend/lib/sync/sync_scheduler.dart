/// Starts and manages periodic sync runs for the whole app.
import 'dart:async';

import 'package:frontend/sync/sync_orchestrator.dart';

class SyncScheduler {
  final SyncOrchestrator _orchestrator;
  Timer? _timer;

  SyncScheduler(this._orchestrator);

  void start() {
    unawaited(_orchestrator.sync());
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => unawaited(_orchestrator.sync()),
    );
  }

  void stop() {
    _timer?.cancel();
  }

  Future<void> syncNow() => _orchestrator.sync();
}
