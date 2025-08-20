import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Call this right after a successful signup (email or social).
/// [isExpert] = true for Wellness Experts, false for Getting Healthy (seeker).
void handlePostSignup(BuildContext context, {required bool isExpert}) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Account created successfully')),
  );
  if (isExpert) {
    context.go('/expert/details');
  } else {
    context.go('/onboard/wellness/body');
  }
}
