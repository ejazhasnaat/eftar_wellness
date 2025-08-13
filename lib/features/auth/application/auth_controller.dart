// lib/features/auth/application/auth_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/auth_repository.dart';
import '../domain/user_path.dart';
import '../data/auth_repository_prefs.dart';

/// Swap this provider later with your real (Supabase) repo via overrides.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryPrefs();
});

