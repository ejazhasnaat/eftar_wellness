// lib/features/auth/data/auth_repository_local.dart
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/auth_repository.dart';

class AuthRepositoryLocal implements AuthRepository {
  static const _kToken = 'auth_token';

  @override
  Future<bool> isSignedIn() async {
    final p = await SharedPreferences.getInstance();
    return (p.getString(_kToken) ?? '').isNotEmpty;
  }

  @override
  Future<void> setSignedInUser(String userId) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, userId);
  }

  @override
  Future<void> signOut() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kToken);
  }
}
