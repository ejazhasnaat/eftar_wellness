import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'conversation_repo.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  const ChatScreen({super.key, required this.otherUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen> {
  final repo = ConversationRepo();
  final ctrl = TextEditingController();
  String? convoId;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final me = Supabase.instance.client.auth.currentUser!.id;
    convoId = await repo.ensureConversation([me, widget.otherUserId]);
    if (mounted) setState((){});
  }

  @override
  Widget build(BuildContext context) {
    if (convoId == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(children: [
        Expanded(
          child: StreamBuilder(
            stream: repo.streamMessages(convoId!),
            builder: (context, snap) {
              if (!snap.hasData) return const SizedBox();
              final msgs = snap.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: msgs.length,
                itemBuilder: (_, i) {
                  final m = msgs[i];
                  final isMe = m['sender_id'] == Supabase.instance.client.auth.currentUser!.id;
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue.shade50 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(m['body'] ?? ''),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Row(children: [
          Expanded(child: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Message...'))),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              await repo.send(convoId!, ctrl.text.trim());
              ctrl.clear();
            },
          )
        ])
      ]),
    );
  }
}
