import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../model/todo_isar.dart';

/// Opens and holds the process-wide Isar instance. Call [init] in [main] before
/// [runApp], after [WidgetsFlutterBinding.ensureInitialized] (see Isar quickstart
/// on pub.dev).
class IsarDb {
  IsarDb._();

  static Isar? _instance;

  static bool get isOpen => _instance != null;

  static Isar get instance {
    final isar = _instance;
    if (isar == null) {
      throw StateError('Isar is not open. Await IsarDb.init() first.');
    }
    return isar;
  }

  static Future<Isar> init() async {
    if (_instance != null) return _instance!;

    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [TodoItemSchema],
      directory: dir.path,
    );
    return _instance!;
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
