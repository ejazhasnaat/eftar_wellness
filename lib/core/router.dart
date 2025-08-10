import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/auth/presentation/register_screen_step1_common.dart';
import '../features/profile/presentation/post_register_redirect_screen.dart';
import '../features/home/presentation/home_user_screen.dart';
import '../features/home/presentation/home_expert_screen.dart';
import '../features/home/presentation/home_provider_screen.dart';
import '../features/home/presentation/home_vendor_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/sign-in', builder: (_, __) => const SignInScreen()),
      GoRoute(path: '/register/step1', builder: (_, __) => const RegisterStep1CommonScreen()),
      GoRoute(path: '/post-register', builder: (_, __) => const PostRegisterRedirectScreen()),
      GoRoute(path: '/home/user', builder: (_, __) => const HomeUserScreen()),
      GoRoute(path: '/home/expert', builder: (_, __) => const HomeExpertScreen()),
      GoRoute(path: '/home/provider', builder: (_, __) => const HomeProviderScreen()),
      GoRoute(path: '/home/vendor', builder: (_, __) => const HomeVendorScreen()),
    ],
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final loggingIn = state.fullPath == '/sign-in' || state.fullPath == '/register/step1';
      if (session == null && !loggingIn) return '/sign-in';
      if (session != null && (state.fullPath == '/sign-in' || state.fullPath == '/register/step1')) {
        return '/post-register';
      }
      return null;
    },
  );
});
