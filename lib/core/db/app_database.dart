// lib/core/db/app_database.dart
import 'dart:io';
import 'dart:io' show Platform;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'package:eftar_wellness/core/db/tables/user_table.dart';
import 'package:eftar_wellness/core/db/tables/meal_table.dart';
import 'package:eftar_wellness/core/db/daos/user_dao.dart';
import 'package:eftar_wellness/core/db/daos/meal_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Users, Meals],
  daos: [UserDao, MealDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Add migrations when bumping schemaVersion.
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    // Avoid using 'package:path' to remove depend_on_referenced_packages info.
    final sep = Platform.pathSeparator;
    final file = File('${dir.path}${sep}eftar.db');
    return NativeDatabase.createInBackground(file);
  });
}

