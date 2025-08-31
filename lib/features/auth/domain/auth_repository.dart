// lib/features/auth/domain/auth_repository.dart
abstract class AuthRepository {
  Future<bool> isSignedIn();
  Future<void> setSignedInUser(String userId);
  Future<void> signOut();
}
