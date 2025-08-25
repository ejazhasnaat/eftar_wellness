import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/kv_store.dart';
import '../../../app/di/providers.dart';
import '../domain/email_verification_service.dart';
import '../data/email_verification_service_dev.dart';
import '../domain/auth_repository.dart';
import '../data/auth_repository_prefs.dart';
import '../../../data/db/app_database.dart';

// DI providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryPrefs();
});

final kvStoreProvider = Provider<KvStore>((ref) => KvStore());

final emailVerificationServiceProvider =
    Provider<EmailVerificationService>((ref) => const DevEmailVerificationService());

final authControllerProvider = Provider<AuthController>((ref) => AuthController(ref));

class AuthController {
  AuthController(this._ref);

  final Ref _ref;

  AuthRepository get _repo => _ref.read(authRepositoryProvider);
  KvStore get _kv => _ref.read(kvStoreProvider);
  EmailVerificationService get _email =>
      _ref.read(emailVerificationServiceProvider);

  // helper keys
  String _codeKey(String userId) => 'ev_code_' + userId;
  String _expKey(String userId) => 'ev_exp_' + userId;
  String _sentKey(String userId) => 'ev_sent_' + userId;
  String _verKey(String userId) => 'ev_verified_' + userId;
  String _uidKey(String email) => 'ev_uid_' + email;
  String _pwdKey(String userId) => 'ev_pwd_' + userId;

  String _hash(String code) => sha256.convert(utf8.encode(code)).toString();

  String _generateCode() {
    final r = Random.secure();
    final n = r.nextInt(900000) + 100000; // 6-digit
    return n.toString();
  }

  Future<void> _sendCode({required String userId, required String email}) async {
    final code = _generateCode();
    await _kv.putString(_codeKey(userId), _hash(code));
    final now = DateTime.now();
    await _kv.putInt(
        _expKey(userId),
        now.add(const Duration(minutes: 10)).millisecondsSinceEpoch);
    await _kv.putInt(_sentKey(userId), now.millisecondsSinceEpoch);
    await _email.sendVerification(email: email, code: code);
  }

  Future<String> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    if (await _kv.getString(_uidKey(email)) != null) {
      throw Exception('Email already in use');
    }
    final id = const Uuid().v4();
    await _kv.putString(_uidKey(email), id);
    await _kv.putBool(_verKey(id), false);
    await _kv.putString(_pwdKey(id), _hash(password));
    final repo = _ref.read(userRepositoryProvider);
    await repo.save(User(
        id: id,
        name: name,
        email: email,
        createdAt: DateTime.now(),
        updatedAt: null));
    await _sendCode(userId: id, email: email);
    return id;
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final userId = await _kv.getString(_uidKey(email));
    if (userId == null) {
      throw Exception('User not found');
    }
    final verified = await isEmailVerified(userId);
    if (!verified) {
      throw Exception('Email not verified');
    }
    final storedHash = await _kv.getString(_pwdKey(userId));
    if (storedHash != _hash(password)) {
      throw Exception('Invalid credentials');
    }
    await _repo.signInWithEmail(email: email, password: password);
  }

  Future<void> signInWithGoogle() => _repo.signInWithGoogle();
  Future<void> signInWithApple() => _repo.signInWithApple();
  Future<void> signOut() => _repo.signOut();

  Future<void> requestPasswordReset({required String email}) async {
    final userId = await _kv.getString(_uidKey(email));
    if (userId == null) {
      throw Exception('User not found');
    }
    await _sendCode(userId: userId, email: email);
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final userId = await _kv.getString(_uidKey(email));
    if (userId == null) {
      throw Exception('User not found');
    }
    await confirmCode(userId: userId, code: code);
    await _kv.putString(_pwdKey(userId), _hash(newPassword));
  }

  Future<void> confirmCode({required String userId, required String code}) async {
    final storedHash = await _kv.getString(_codeKey(userId));
    final exp = await _kv.getInt(_expKey(userId)) ?? 0;
    if (storedHash == null || exp < DateTime.now().millisecondsSinceEpoch) {
      throw Exception('Code expired');
    }
    if (_hash(code) != storedHash) {
      throw Exception('Invalid code');
    }
    await _kv.putBool(_verKey(userId), true);
    await _kv.remove(_codeKey(userId));
    await _kv.remove(_expKey(userId));
  }

  Future<void> resend({required String userId, required String email}) async {
    final last = await _kv.getInt(_sentKey(userId)) ?? 0;
    if (DateTime.now().millisecondsSinceEpoch - last < 60000) {
      throw Exception('Please wait before requesting another code');
    }
    await _sendCode(userId: userId, email: email);
  }

  Future<bool> isEmailVerified(String userId) async {
    return await _kv.getBool(_verKey(userId)) ?? false;
  }
}
