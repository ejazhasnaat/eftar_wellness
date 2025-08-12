// lib/features/experts/expert_clients_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart'; // <-- NEW

class ExpertClientsScreen extends StatefulWidget {
  const ExpertClientsScreen({super.key});
  @override
  State<ExpertClientsScreen> createState() => _ExpertClientsScreenState();
}

class _ExpertClientsScreenState extends State<ExpertClientsScreen> {
  final _sb = Supabase.instance.client;
  List<Map<String, dynamic>> clients = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // For now, show last 20 conversations for this expert.
    final me = _sb.auth.currentUser!.id;
    final rows = await _sb
        .from('conversations')
        .select('id, participants')
        .contains('participants', [me])
        .order('updated_at', ascending: false)
        .limit(20);

    clients = rows.map<Map<String, dynamic>>((r) {
      final others =
          List<String>.from(r['participants']).where((x) => x != me).toList();
      return {
        'conversation_id': r['id'],
        'other_id': others.isEmpty ? me : others.first
      };
    }).toList();

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Clients')),
      body: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (_, i) {
          final c = clients[i];
          final otherId = c['other_id'] as String;
          return ListTile(
            title: Text(otherId),
            subtitle: const Text('Tap to chat'),
            onTap: () {
              // GoRouter: /chat/:otherUserId
              context.pushNamed('chat', pathParameters: {'otherUserId': otherId});
              // or: context.go('/chat/$otherId');
            },
          );
        },
      ),
    );
  }
}

