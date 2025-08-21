// lib/features/ai_assistant/presentation/screens/ai_chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/intent.dart';
import '../../application/providers.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/smart_action_chips.dart';

class AiChatScreen extends ConsumerWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assistantControllerProvider);
    final controller = ref.read(assistantControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Wellness Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final msg = state.messages[index];
                return MessageBubble(message: msg);
              },
            ),
          ),
          SmartActionChips(
            onSelected: (intent) {
              controller.handleIntent(Intent(intent));
            },
          ),
          ChatInputBar(
            onSend: controller.send,
          ),
        ],
      ),
    );
  }
}
