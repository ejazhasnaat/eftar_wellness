// lib/features/auth/data/auth_repository_prefs.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eftar_wellness/features/auth/domain/auth_repository.dart';
import 'package:eftar_wellness/features/auth/domain/user_path.dart';

class AuthRepositoryPrefs implements AuthRepository {
  static const _kToken   = 'auth_token';
  static const _kPath    = 'user_path';
  static const _kCity    = 'city';
  static const _kCountry = 'country';

  @override
  Future<bool> isSignedIn() async {
    final p = await SharedPreferences.getInstance();
    return (p.getString(_kToken) ?? '').isNotEmpty;
  }

  @override
  Future<void> signOut() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kToken);
  }

  @override
  Future<void> signInWithGoogle() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, 'google_dummy_token');
  }

  @override
  Future<void> signInWithApple() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, 'apple_dummy_token');
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
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, 'email_dummy_token');
    await p.setString(_kPath, path.name);
    if (city != null) await p.setString(_kCity, city);
    if (country != null) await p.setString(_kCountry, country);
    return email;
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, 'email_dummy_token');
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    // no-op for local prefs auth
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    // no-op for local prefs auth
  }

  @override
  Stream<dynamic> get onAuthStateChanged => const Stream.empty();
}
