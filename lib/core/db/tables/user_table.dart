import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uid => text().unique()(); // maps to Supabase uid later
  TextColumn get supabaseUserId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  BoolColumn get emailVerified => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

