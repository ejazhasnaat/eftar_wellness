import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/db/app_database.dart';
import 'di/providers.dart';
import 'env/env.dart';

Future<ProviderContainer> bootstrap() async {
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
  final container = ProviderContainer(overrides: [
    dbProvider.overrideWithValue(AppDatabase()),
  ]);
  return container;
}
