import '../../domain/repositories/user_repository.dart';
import '../db/app_database.dart';
import '../db/daos/user_dao.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDao _dao;
  UserRepositoryImpl(this._dao);

  @override
  Stream<List<User>> watchAll() => _dao.watchAll();

  @override
  Future<void> save(User row) => _dao.upsert(row);

  @override
  Future<void> remove(String id) => _dao.deleteById(id);
}
