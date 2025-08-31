import '../../data/db/app_database.dart';

abstract class UserRepository {
  Stream<List<User>> watchAll();
  Future<User?> getByEmail(String email);
  Future<User?> getById(String id);
  Future<void> save(User row);
  Future<void> remove(String id);
}
