// lib/app/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/screens/home_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/signin_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/onboarding/presentation/expert_details_screen.dart';
import '../features/onboarding/presentation/approval_status_screen.dart';
import '../features/wellness_profile/presentation/body_step_screen.dart';
import '../features/wellness_profile/presentation/goals_step_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
          path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(
          path: '/signin', builder: (context, state) => const SignInScreen()),
      GoRoute(
          path: '/signup', builder: (context, state) => const SignUpScreen()),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen()),
      GoRoute(
          path: '/onboard/expert',
          builder: (context, state) => const ExpertDetailsScreen()),
      GoRoute(
          path: '/expert/approval-status',
          builder: (context, state) => const ExpertApprovalStatusScreen()),
      GoRoute(
          path: '/onboard/wellness/body',
          builder: (context, state) => const BodyStepScreen()),
      GoRoute(
          path: '/onboard/wellness/goals',
          builder: (context, state) => const GoalsStepScreen()),
    ],
  );
});
