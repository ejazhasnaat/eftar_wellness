import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'meal_dao.g.dart';

@DriftAccessor(tables: [Meals])
class MealDao extends DatabaseAccessor<AppDatabase> with _$MealDaoMixin {
  MealDao(AppDatabase db) : super(db);

  Future<List<Meal>> byUser(String userId) =>
      (select(meals)..where((m) => m.userId.equals(userId))).get();

  Stream<List<Meal>> watchByUser(String userId) =>
      (select(meals)..where((m) => m.userId.equals(userId))).watch();

  Future<void> upsert(Meal row) => into(meals).insertOnConflictUpdate(row);
}
