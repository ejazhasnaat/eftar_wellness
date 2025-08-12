// lib/core/router.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Screens
import 'package:eftar_wellness/features/auth/presentation/splash_screen.dart';
import 'package:eftar_wellness/features/auth/presentation/sign_in_screen.dart';
import 'package:eftar_wellness/features/auth/presentation/signup_screen.dart';
import 'package:eftar_wellness/features/profile/presentation/post_register_redirect_screen.dart';
import 'package:eftar_wellness/features/home/presentation/home_user_screen.dart';
import 'package:eftar_wellness/features/home/presentation/home_expert_screen.dart';
import 'package:eftar_wellness/features/home/presentation/home_provider_screen.dart';
import 'package:eftar_wellness/features/home/presentation/home_vendor_screen.dart';
import 'package:eftar_wellness/features/assistant/assistant_screen.dart';
import 'package:eftar_wellness/features/onboarding/presentation/step2_expert_screen.dart'
    as step2_expert;
import 'package:eftar_wellness/features/onboarding/presentation/expert_details_screen.dart';
import 'package:eftar_wellness/features/onboarding/domain/expert_kind.dart'; // <-- shared enum

class _AuthRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;
  _AuthRefreshNotifier() {
    final auth = Supabase.instance.client.auth;
    _sub = auth.onAuthStateChange.listen((_) => notifyListeners());
  }
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class AppRouter {
  AppRouter._();

  static final _authRefresh = _AuthRefreshNotifier();

  static String? _redirect(BuildContext context, GoRouterState state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isAuthed = session != null;

    final loc = state.uri.toString();
    final isAuthRoute =
        loc == '/signin' ||
        loc == '/sign-in' || // alias
        loc == '/login' || // alias
        loc == '/signup' ||
        loc == '/register' ||
        loc.startsWith('/register/');
    final isSplash = loc == '/' || loc.startsWith('/splash');

    if (!isAuthed) {
      if (isSplash || isAuthRoute) return null; // allow auth screens
      return '/signin';
    }
    if (isAuthRoute || isSplash) return '/post-register';
    return null;
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: _authRefresh,
    redirect: _redirect,
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),

      // --- Auth routes + aliases ---
      GoRoute(
        path: '/signin',
        name: 'signin',
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        name: 'signin_alias',
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login_alias',
        builder: (_, __) => const SignInScreen(),
      ),

      // Legacy register path (kept)
      GoRoute(
        path: '/register',
        name: 'register_legacy',
        builder: (_, __) => const SignUpScreen(),
      ),
      // Old wizard-style path: /register/step1 -> signup
      GoRoute(
        path: '/register/step1',
        name: 'register_step1_alias',
        builder: (_, __) => const SignUpScreen(),
      ),
      // Catch-all under /register/* -> signup (e.g., /register/anything)
      GoRoute(
        path: '/register/:rest(.*)',
        name: 'register_catch_all',
        builder: (_, __) => const SignUpScreen(),
      ),

      // New canonical signup
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (_, __) => const SignUpScreen(),
      ),

      // Post-auth guard screen
      GoRoute(
        path: '/post-register',
        name: 'post_register',
        builder: (_, __) => const PostRegisterRedirectScreen(),
      ),

      // Expert review/status (existing)
      GoRoute(
        path: '/expert/approval-status',
        name: 'expert_approval_status',
        builder: (_, __) => const step2_expert.Step2ExpertScreen(),
      ),

      // NEW: Expert details screen
      GoRoute(
        path: '/expert/details',
        name: 'expert_details',
        builder: (_, state) {
          final extra = state.extra;
          ExpertKind? suggested;
          if (extra is Map && extra['suggestedKind'] is ExpertKind) {
            suggested = extra['suggestedKind'] as ExpertKind;
          }
          return ExpertDetailsScreen(suggestedKind: suggested);
        },
      ),

      // --- Homes (role-based) ---
      GoRoute(
        path: '/home/user',
        name: 'home_user',
        builder: (_, __) => const HomeUserScreen(),
      ),
      GoRoute(
        path: '/home/expert',
        name: 'home_expert',
        builder: (_, __) => const HomeExpertScreen(),
      ),
      GoRoute(
        path: '/home/provider',
        name: 'home_provider',
        builder: (_, __) => const HomeProviderScreen(),
      ),
      GoRoute(
        path: '/home/vendor',
        name: 'home_vendor',
        builder: (_, __) => const HomeVendorScreen(),
      ),

      // Example feature
      GoRoute(
        path: '/assistant',
        name: 'assistant',
        builder: (_, __) => const AssistantScreen(),
      ),
    ],
  );
}

// Riverpod provider used by App
final goRouterProvider = Provider<GoRouter>((ref) => AppRouter.router);
