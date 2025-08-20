// lib/core/db/daos/user_dao.dart
import 'package:drift/drift.dart';
import 'package:eftar_wellness/core/db/app_database.dart';
import 'package:eftar_wellness/core/db/tables/user_table.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);
  // If super parameter not desired, use: UserDao(AppDatabase db) : super(db);

  Future<int> upsertUser(UsersCompanion data) =>
      into(users).insertOnConflictUpdate(data);

  Future<User?> getByUid(String uid) =>
      (select(users)..where((t) => t.uid.equals(uid))).getSingleOrNull();
}

