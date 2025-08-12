// lib/features/profile/presentation/post_register_redirect_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostRegisterRedirectScreen extends StatefulWidget {
  const PostRegisterRedirectScreen({super.key});

  @override
  State<PostRegisterRedirectScreen> createState() =>
      _PostRegisterRedirectScreenState();
}

class _PostRegisterRedirectScreenState
    extends State<PostRegisterRedirectScreen> {
  final _sb = Supabase.instance.client;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    try {
      final session = _sb.auth.currentSession;
      final uid = session?.user.id;
      if (uid == null) {
        if (!mounted) return;
        context.go('/signin');
        return;
      }

      // Fetch role
      final profRes = await _sb
          .from('profiles')
          .select('id, role') // <- no generic type arg
          .eq('id', uid)
          .maybeSingle();

      final role = (profRes?['role'] as String?)?.trim().toLowerCase() ?? 'user';

      switch (role) {
        case 'expert':
          await _routeExpert(uid);
          return;
        case 'provider':
          if (!mounted) return;
          context.go('/home/provider');
          return;
        case 'vendor':
          if (!mounted) return;
          context.go('/home/vendor');
          return;
        case 'admin':
          if (!mounted) return;
          context.go('/home/user'); // adjust if you have an admin home
          return;
        case 'user':
        default:
          if (!mounted) return;
          context.go('/home/user');
          return;
      }
    } catch (e) {
      setState(() => _error = e);
    }
  }

  Future<void> _routeExpert(String uid) async {
    try {
      final exp = await _sb
          .from('expert_profiles')
          .select('status')
          .eq('user_id', uid)
          .maybeSingle();

      final status = (exp?['status'] as String?)?.toLowerCase() ?? 'pending';

      if (!mounted) return;
      if (status == 'approved') {
        context.go('/home/expert');
      } else {
        // pending / rejected / missing → to status page
        context.go('/expert/approval-status');
      }
    } catch (_) {
      if (!mounted) return;
      context.go('/expert/approval-status');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Redirecting')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: theme.colorScheme.error),
                const SizedBox(height: 12),
                const Text('We hit a snag while redirecting.', textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('You can continue manually.', style: theme.textTheme.bodySmall),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    OutlinedButton(onPressed: () => context.go('/home/user'), child: const Text('Home (User)')),
                    OutlinedButton(onPressed: () => context.go('/expert/approval-status'), child: const Text('Expert Status')),
                    OutlinedButton(onPressed: () => context.go('/signin'), child: const Text('Sign in')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

