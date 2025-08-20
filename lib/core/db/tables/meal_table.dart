import 'package:drift/drift.dart';

class Meals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userUid => text()();                 // FK to Users.uid (logical)
  TextColumn get title => text()();
  TextColumn get photoPath => text().nullable()();
  IntColumn get calories => integer().nullable()();
  DateTimeColumn get loggedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

