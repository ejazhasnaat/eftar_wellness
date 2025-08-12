// lib/features/home/presentation/home_expert_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeExpertScreen extends StatefulWidget {
  const HomeExpertScreen({super.key});

  @override
  State<HomeExpertScreen> createState() => _HomeExpertScreenState();
}

class _HomeExpertScreenState extends State<HomeExpertScreen> {
  Map<String, dynamic>? _data;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return;

    final row =
        await client.from('experts').select().eq('user_id', uid).maybeSingle();
    if (mounted) {
      setState(() => _data = row);
    }
  }

  Widget _statusChip(String status) {
    Color? color;
    Color? txt;
    switch (status) {
      case 'approved':
        color = Colors.green.shade100;
        txt = Colors.green.shade800;
        break;
      case 'rejected':
        color = Colors.red.shade100;
        txt = Colors.red.shade800;
        break;
      case 'pending':
      default:
        color = Colors.amber.shade100;
        txt = Colors.amber.shade900;
    }
    return Chip(
      label: Text(status.toUpperCase()),
      backgroundColor: color,
      labelStyle: TextStyle(fontWeight: FontWeight.w600, color: txt),
    );
  }

  Widget _pendingBanner() => Card(
        color: Colors.amber.shade50,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading:
              const Icon(Icons.hourglass_bottom_rounded, color: Colors.amber),
          title: const Text('Your expert account is pending approval'),
          subtitle: const Text(
            'We’ll notify you once an admin reviews your profile.',
          ),
          trailing: TextButton.icon(
            onPressed: () => context.go('/onboarding/step2/expert'),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit profile'),
          ),
        ),
      );

  Widget _rejectedBanner() => Card(
        color: Colors.red.shade50,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: const Icon(Icons.error_outline_rounded, color: Colors.red),
          title: const Text('Your expert account was rejected'),
          subtitle: const Text(
              'Please update your profile and resubmit for approval.'),
          trailing: TextButton.icon(
            onPressed: () => context.go('/onboarding/step2/expert'),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit profile'),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final status = (_data?['approval_status'] as String?) ?? 'pending';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Expert Home'),
            Text(
              'Approval: ${status.toUpperCase()}',
              style: TextStyle(
                fontSize: 12,
                color: status == 'approved'
                    ? Colors.green.shade700
                    : status == 'pending'
                        ? Colors.amber.shade800
                        : Colors.red.shade700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            onPressed: () => context.go('/onboarding/step2/expert'),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _data == null
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Complete your onboarding',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We don’t see your expert profile yet. '
                    'Please complete Step 2 to submit your account for approval.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => context.go('/onboarding/step2/expert'),
                    icon: const Icon(Icons.playlist_add_check_rounded),
                    label: const Text('Go to Step 2'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    _statusChip(status),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/onboarding/step2/expert'),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit profile'),
                    ),
                  ],
                ),
                if (status == 'pending') _pendingBanner(),
                if (status == 'rejected') _rejectedBanner(),
              ],
            ),
    );
  }
}

