// lib/core/db/daos/meal_dao.dart
import 'package:drift/drift.dart';
import 'package:eftar_wellness/core/db/app_database.dart';
import 'package:eftar_wellness/core/db/tables/meal_table.dart';

part 'meal_dao.g.dart';

@DriftAccessor(tables: [Meals])
class MealDao extends DatabaseAccessor<AppDatabase> with _$MealDaoMixin {
  MealDao(super.db);
  // If super parameter not desired, use: MealDao(AppDatabase db) : super(db);

  Future<int> addMeal(MealsCompanion data) => into(meals).insert(data);

  Stream<List<Meal>> watchMealsForUser(String uid) =>
      (select(meals)
            ..where((m) => m.userUid.equals(uid))
            ..orderBy([(m) => OrderingTerm.desc(m.loggedAt)]))
          .watch();
}

