import 'package:drift/drift.dart';

class TodoTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text().withLength(min: 1, max: 32)();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  // version for sync correctness
  IntColumn get version => integer().withDefault(const Constant(0))();

  // metadata
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // offline state
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus =>
      text().withLength(min: 1, max: 16).withDefault(const Constant('pending'))();
}
