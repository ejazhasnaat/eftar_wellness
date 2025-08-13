import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/db/app_database.dart';
import 'di/providers.dart';

Future<ProviderContainer> bootstrap() async {
  final container = ProviderContainer(overrides: [
    dbProvider.overrideWithValue(AppDatabase()),
  ]);
  return container;
}
