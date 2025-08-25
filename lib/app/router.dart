// lib/app/router.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:eftar_wellness/features/home/presentation/screens/home_screen.dart';
import 'package:eftar_wellness/features/settings/presentation/screens/settings_screen.dart';
import 'package:eftar_wellness/features/auth/presentation/screens/splash_screen.dart';
import 'package:eftar_wellness/features/auth/presentation/screens/signin_screen.dart';
import 'package:eftar_wellness/features/auth/presentation/screens/signup_screen.dart';
import 'package:eftar_wellness/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:eftar_wellness/features/onboarding/presentation/expert_details_screen.dart';
import 'package:eftar_wellness/features/onboarding/presentation/approval_status_screen.dart';
import 'package:eftar_wellness/features/wellness_profile/presentation/body_step_screen.dart';
import 'package:eftar_wellness/features/wellness_profile/presentation/goals_step_screen.dart';
import 'package:eftar_wellness/features/ai_assistant/presentation/screens/ai_chat_screen.dart';
import 'package:eftar_wellness/features/profile/presentation/profile_edit_screen.dart';

/// Builds the app router. Paths and screens preserved deliberately.
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: <RouteBase>[
      // Home & settings
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'profile_edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),

      // Auth
      GoRoute(
        path: '/auth/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/signin',
        name: 'signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        name: 'signup',
        // Uses SignUpScreen (capital U) intentionally
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/auth/reset-password',
        name: 'reset_password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      // Onboarding (experts)
      GoRoute(
        path: '/expert/details',
        name: 'expert_details',
        builder: (context, state) => const ExpertDetailsScreen(),
      ),
      GoRoute(
        path: '/expert/approval-status',
        name: 'expert_approval_status',
        builder: (context, state) => const ExpertApprovalStatusScreen(),
      ),

      // Onboarding (wellness profile)
      GoRoute(
        path: '/onboard/wellness/body',
        name: 'onboard_wellness_body',
        builder: (context, state) => const BodyStepScreen(),
      ),
      GoRoute(
        path: '/onboard/wellness/goals',
        name: 'onboard_wellness_goals',
        builder: (context, state) => const GoalsStepScreen(),
      ),

      // AI Assistant
      GoRoute(
        path: '/assistant',
        name: 'assistant',
        builder: (context, state) => const AiChatScreen(),
      ),
      GoRoute(
        path: '/assistant/chat',
        name: 'assistant_chat',
        builder: (context, state) => const AiChatScreen(),
      ),

      // Optional landing redirect (no-op safe)
      GoRoute(
        path: '/',
        name: 'root_redirect',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}

/// Expose a provider here too if you prefer consuming directly from this file.
final routerProvider = Provider<GoRouter>((ref) => buildRouter());

