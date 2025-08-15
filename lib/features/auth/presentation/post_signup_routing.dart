import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Call this right after a successful signup (email or social).
/// [isExpert] = true for Wellness Experts, false for Getting Healthy (seeker).
void handlePostSignup(BuildContext context, {required bool isExpert}) {
  // Notify creation
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Account created successfully')),
  );

  // Route by user path
  if (isExpert) {
    context.go('/onboard/expert');              // opens ExpertDetailsScreen
  } else {
    context.go('/onboard/wellness/body');       // opens wellness micro-onboarding
  }
}

