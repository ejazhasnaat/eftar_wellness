import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import 'daos/user_dao.dart';
import 'daos/meal_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Users, Meals], daos: [UserDao, MealDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {},
      );
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'wellness.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
