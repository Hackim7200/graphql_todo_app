import 'package:isar/isar.dart';

part 'todo_isar.g.dart';

/// Local cache for [Todo] from the API. Isar [Id] is int; the GraphQL `id` is
/// stored in [serverId] (unique) for upsert and lookups.
@collection
class TodoItem {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  late String title;

  late bool isCompleted;
}
