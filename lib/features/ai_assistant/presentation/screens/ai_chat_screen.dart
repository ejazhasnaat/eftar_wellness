// lib/features/ai_assistant/presentation/screens/ai_chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/intent.dart' as ai;
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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Wellness Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: state.messages.isEmpty
                ? _EmptyAssistantHint(color: cs.onSurfaceVariant)
                : ListView.builder(
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
              controller.handleIntent(ai.Intent(intent));
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

/* --------------------------- EMPTY CHAT HINT ------------------------------ */

class _EmptyAssistantHint extends StatelessWidget {
  const _EmptyAssistantHint({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                'Meet your AI Wellness Assistant',
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your personal coach for meals, workouts, and daily wellness. '
                'I adapt to your goals and suggest quick Smart Actions.',
                style: t.bodyMedium?.copyWith(color: color),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _HintBullet(
                icon: Icons.fastfood_outlined,
                text: 'Scan meals for calories, nutrition, and healthier swaps.',
                color: color,
              ),
              _HintBullet(
                icon: Icons.mic_none_outlined,
                text: 'Hands-free voice coaching with timely prompts.',
                color: color,
              ),
              _HintBullet(
                icon: Icons.self_improvement_outlined,
                text: 'Quick mental resets: breathing, focus, and confidence.',
                color: color,
              ),
              _HintBullet(
                icon: Icons.emoji_events_outlined,
                text: 'Join challenges, track streaks, and earn achievements.',
                color: color,
              ),
              _HintBullet(
                icon: Icons.event_outlined,
                text: 'Plan meals, workouts, and recovery into your day.',
                color: color,
              ),
              _HintBullet(
                icon: Icons.hourglass_top_outlined,
                text: 'Explore fasting cycles, recovery, and longevity tips.',
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                'Tip: Use Smart Action Chips (Log Water, Log Meal, Start Run) '
                'or tap the mic to begin.',
                style: t.bodySmall?.copyWith(color: color),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HintBullet extends StatelessWidget {
  const _HintBullet(
      {required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: t.bodyMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

