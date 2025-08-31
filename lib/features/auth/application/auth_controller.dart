import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/kv_store.dart';
import '../../../app/di/providers.dart';
import '../domain/email_verification_service.dart';
import '../data/email_verification_service_dev.dart';
import '../domain/auth_repository.dart';
import '../data/auth_repository_local.dart';
import '../domain/user_path.dart';
import '../../../data/db/app_database.dart';

// DI providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryLocal();
});

final kvStoreProvider = Provider<KvStore>((ref) => KvStore());

final emailVerificationServiceProvider =
    Provider<EmailVerificationService>((ref) {
  return const DevEmailVerificationService();
});

final authControllerProvider = Provider<AuthController>((ref) => AuthController(ref));

class AuthController {
  AuthController(this._ref);

  final Ref _ref;

  AuthRepository get _repo => _ref.read(authRepositoryProvider);
  KvStore get _kv => _ref.read(kvStoreProvider);
  EmailVerificationService get _email =>
      _ref.read(emailVerificationServiceProvider);

  // helper keys for verification codes
  String _codeKey(String userId) => 'ev_code_' + userId;
  String _expKey(String userId) => 'ev_exp_' + userId;
  String _sentKey(String userId) => 'ev_sent_' + userId;

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
    required UserPath path,
  }) async {
    final repo = _ref.read(userRepositoryProvider);
    final existing = await repo.getByEmail(email);
    if (existing != null) {
      throw Exception('Email already in use');
    }
    final id = const Uuid().v4();
    await repo.save(User(
      id: id,
      name: name,
      email: email,
      passwordHash: _hash(password),
      emailVerified: false,
      createdAt: DateTime.now(),
      updatedAt: null,
    ));
    await _sendCode(userId: id, email: email);
    return id;
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final repo = _ref.read(userRepositoryProvider);
    final user = await repo.getByEmail(email);
    if (user == null) {
      throw Exception('User not found');
    }
    if (!user.emailVerified) {
      throw Exception('Email not verified');
    }
    if (user.passwordHash != _hash(password)) {
      throw Exception('Invalid credentials');
    }
    await _repo.setSignedInUser(user.id);
  }

  Future<void> signOut() => _repo.signOut();

  Future<void> requestPasswordReset({required String email}) async {
    final repo = _ref.read(userRepositoryProvider);
    final user = await repo.getByEmail(email);
    if (user == null) {
      throw Exception('User not found');
    }
    await _sendCode(userId: user.id, email: email);
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final repo = _ref.read(userRepositoryProvider);
    final user = await repo.getByEmail(email);
    if (user == null) {
      throw Exception('User not found');
    }
    await confirmCode(userId: user.id, email: email, code: code);
    await repo.save(user.copyWith(
      passwordHash: _hash(newPassword),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> confirmCode({
    required String userId,
    required String email,
    required String code,
  }) async {
    final storedHash = await _kv.getString(_codeKey(userId));
    final exp = await _kv.getInt(_expKey(userId)) ?? 0;
    if (storedHash == null || exp < DateTime.now().millisecondsSinceEpoch) {
      throw Exception('Code expired');
    }
    if (_hash(code) != storedHash) {
      throw Exception('Invalid code');
    }
    final repo = _ref.read(userRepositoryProvider);
    final user = await repo.getById(userId);
    if (user != null) {
      await repo.save(user.copyWith(
        emailVerified: true,
        updatedAt: Value(DateTime.now()),
      ));
    }
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
}
