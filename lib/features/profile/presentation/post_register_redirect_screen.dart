import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/role.dart';

class PostRegisterRedirectScreen extends StatefulWidget {
  const PostRegisterRedirectScreen({super.key});

  @override
  State<PostRegisterRedirectScreen> createState() => _PostRegisterRedirectScreenState();
}

class _PostRegisterRedirectScreenState extends State<PostRegisterRedirectScreen> {
  final _client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    final repo = ProfileRepository(_client);
    final profile = await repo.getProfile();
    final role = roleFromString(profile?['role'] as String?);
    if (!mounted) return;
    switch (role) {
      case UserRole.expert:
        context.go('/home/expert');
        break;
      case UserRole.provider:
        context.go('/home/provider');
        break;
      case UserRole.vendor:
        context.go('/home/vendor');
        break;
      case UserRole.admin:
        // admins will eventually go to admin dashboard (web)
        context.go('/home/user');
        break;
      case UserRole.user:
      default:
        context.go('/home/user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
