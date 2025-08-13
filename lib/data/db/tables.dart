import 'package:drift/drift.dart';

class Users extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get email => text().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class Meals extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get title => text()();
  IntColumn get calories => integer().withDefault(const Constant(0))();
  DateTimeColumn get loggedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}
