// lib/features/auth/application/auth_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:eftar_wellness/features/auth/domain/auth_repository.dart';
import 'package:eftar_wellness/features/auth/domain/user_path.dart';
import 'package:eftar_wellness/features/auth/data/auth_repository_prefs.dart';

/// DI: repository implementation (Prefs for now; swap to remote later)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryPrefs();
});

/// Lightweight auth state for UI: loading/error + signed-in flag.
/// (Extend with user data later when your repository exposes it.)
class AuthState {
  final bool isLoading;
  final String? error;
  final bool isSignedIn;

  const AuthState({
    required this.isLoading,
    required this.isSignedIn,
    this.error,
  });

  const AuthState.initial()
      : isLoading = false,
        isSignedIn = false,
        error = null;

  AuthState copyWith({
    bool? isLoading,
    bool? isSignedIn,
    String? error, // pass empty string to clear error
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      error: error == '' ? null : (error ?? this.error),
    );
  }
}

/// Primary state provider (watch this for reactive UI).
final authStateProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

/// Back-compat alias so existing screens that do:
///   ref.read(authControllerProvider).signInWithEmail(...)
/// continue to work without edits.
/// It returns the controller (not state).
final authControllerProvider = Provider<AuthController>((ref) {
  return ref.read(authStateProvider.notifier);
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState.initial());

  final Ref _ref;

  AuthRepository get _repo => _ref.read(authRepositoryProvider);

  /// Initialize session (e.g., from SplashScreen).
  Future<void> loadSession() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final signedIn = await _repo.isSignedIn();
      state = state.copyWith(isLoading: false, isSignedIn: signedIn, error: '');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '$e', isSignedIn: false);
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      await _repo.signInWithEmail(email: email, password: password);
      state = state.copyWith(isLoading: false, isSignedIn: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, isSignedIn: false, error: '$e');
      return false;
    }
  }

  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? city,
    String? country,
    required UserPath path,
  }) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      await _repo.signUpWithEmail(
        name: name,
        email: email,
        password: password,
        phone: phone,
        city: city,
        country: country,
        path: path,
      );
      state = state.copyWith(isLoading: false, isSignedIn: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, isSignedIn: false, error: '$e');
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      await _repo.signInWithGoogle();
      state = state.copyWith(isLoading: false, isSignedIn: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, isSignedIn: false, error: '$e');
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      await _repo.signInWithApple();
      state = state.copyWith(isLoading: false, isSignedIn: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, isSignedIn: false, error: '$e');
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      await _repo.signOut();
    } catch (_) {
      // ignore errors for UX parity
    } finally {
      state = const AuthState.initial();
    }
  }
}

