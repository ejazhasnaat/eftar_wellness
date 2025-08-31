import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/auth_repository.dart';
import '../../domain/user_path.dart';

class AuthRepositorySupabase implements AuthRepository {
  AuthRepositorySupabase(this._client);

  final SupabaseClient _client;

  @override
  Future<bool> isSignedIn() async => _client.auth.currentSession != null;

  AuthException _mapError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return AuthException('Invalid credentials');
    } else if (msg.contains('email not confirmed')) {
      return AuthException('Email not confirmed');
    } else if (msg.contains('user not found')) {
      return AuthException('User not found');
    } else if (msg.contains('too many')) {
      return AuthException('Too many requests');
    }
    return e;
  }

  @override
  Future<String> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? city,
    String? country,
    required UserPath path,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': path.name,
          if (phone != null) 'phone': phone,
          if (city != null) 'city': city,
          if (country != null) 'country': country,
        },
      );
      final userId = res.user?.id;
      if (userId == null) {
        throw AuthException('Signup failed');
      }
      return userId;
    } on AuthException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(OAuthProvider.google);
  }

  @override
  Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(OAuthProvider.apple);
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final res = await _client.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.recovery,
      );
      if (res.session == null) {
        throw const AuthException('Invalid code');
      }
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Stream<AuthState> get onAuthStateChanged => _client.auth.onAuthStateChange;
}
