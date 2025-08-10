import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    final auth = Supabase.instance.client.auth;
    auth.onAuthStateChange.listen((event) {
      if (!mounted) return;
      final session = event.session ?? auth.currentSession;
      if (session == null) {
        context.go('/sign-in');
      } else {
        context.go('/post-register');
      }
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        context.go('/sign-in');
      } else {
        context.go('/post-register');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
