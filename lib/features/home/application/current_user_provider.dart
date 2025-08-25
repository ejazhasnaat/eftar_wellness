import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../data/db/app_database.dart';

/// Stream provider exposing the first (and only) signed up user.
final currentUserProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.watchAll().map((users) => users.isNotEmpty ? users.first : null);
});

