// lib/features/auth/domain/auth_repository.dart
import 'package:eftar_wellness/features/auth/domain/user_path.dart';

abstract class AuthRepository {
  Future<bool> isSignedIn();
  Future<void> signOut();

  Future<void> signInWithGoogle();
  Future<void> signInWithApple();

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? city,
    String? country,
    required UserPath path,
  });

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });
}
