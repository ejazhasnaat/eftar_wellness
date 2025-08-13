import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(AppDatabase db) : super(db);

  Future<List<User>> getAll() => select(users).get();
  Stream<List<User>> watchAll() => select(users).watch();

  Future<void> upsert(User row) => into(users).insertOnConflictUpdate(row);

  Future<void> deleteById(String id) =>
      (delete(users)..where((t) => t.id.equals(id))).go();
}
