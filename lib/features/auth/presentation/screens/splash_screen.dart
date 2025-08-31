import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:eftar_wellness/features/auth/application/auth_controller.dart';
import 'package:eftar_wellness/core/constants/feature_flags.dart';
import 'package:eftar_wellness/app/di/providers.dart';
import 'verify_email_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Defer to next event loop to avoid setState during build.
    scheduleMicrotask(() async {
      if (FeatureFlags.useSupabaseAuth) {
        final client = ref.read(supabaseClientProvider);
        final session = client.auth.currentSession;
        if (!mounted) return;
        if (session != null) {
          if (session.user.emailConfirmedAt != null) {
            context.go('/home');
          } else {
            final ok = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => VerifyEmailScreen(
                      userId: session.user.id,
                      email: session.user.email ?? '',
                    ),
                  ),
                ) ??
                false;
            if (!mounted) return;
            if (ok) {
              context.go('/home');
            } else {
              context.go('/auth/signin');
            }
          }
        } else {
          context.go('/auth/signin');
        }
      } else {
        final signedIn = await ref.read(authRepositoryProvider).isSignedIn();
        if (!mounted) return;
        if (signedIn) {
          context.go('/home');
        } else {
          context.go('/auth/signin');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Text(
                'E',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Text('EFTAR', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
