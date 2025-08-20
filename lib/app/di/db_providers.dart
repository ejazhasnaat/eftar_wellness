import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/app_database.dart';
import '../../core/db/daos/meal_dao.dart';
import '../../core/db/daos/user_dao.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final userDaoProvider = Provider<UserDao>((ref) {
  return UserDao(ref.read(dbProvider));
});

final mealDaoProvider = Provider<MealDao>((ref) {
  return MealDao(ref.read(dbProvider));
});

