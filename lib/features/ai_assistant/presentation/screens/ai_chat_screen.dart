import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/ai_chat_controller.dart';
import '../../domain/ai_message.dart';
import '../../../../core/constants/feature_flags.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiChatControllerProvider);
    final controller = ref.read(aiChatControllerProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'AI Wellness Assistant',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          IconButton(
            tooltip: 'Clear chat',
            icon: const Icon(Icons.clear_all),
            onPressed: controller.clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _EmptyAssistantHint(color: cs.onSurfaceVariant)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final m = messages[index];
                      return Align(
                        alignment: m.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: m.isUser
                                ? cs.primaryContainer
                                : cs.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(m.content),
                        ),
                      );
                    },
                  ),
          ),
          _InputBar(
            controller: _textController,
            onSend: (text) async {
              final trimmed = text.trim();
              if (trimmed.isEmpty) return;
              await controller.sendText(trimmed);
              _textController.clear();
              // Ensure we auto-scroll to the latest message
              await Future.delayed(const Duration(milliseconds: 50));
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent + 60,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            },
          ),
        ],
      ),
      bottomNavigationBar:
          _AssistantBottomBar(onScanMeal: controller.analyzeMeal),
    );
  }
}

class _InputBar extends ConsumerWidget {
  const _InputBar({required this.controller, required this.onSend});
  final TextEditingController controller;
  final Future<void> Function(String text) onSend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canVoice = FeatureFlags.aiAssistantVoice;
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final hasText = value.text.trim().isNotEmpty;
                  return TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Ask Wellness AI...',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: IconButton(
                        tooltip: 'Send',
                        onPressed: hasText ? () => onSend(controller.text) : null,
                        icon: Icon(
                          Icons.send_rounded,
                          // Disabled == grey (onSurfaceVariant), Enabled == primary (matches mic bg)
                          color: hasText ? cs.primary : cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    onSubmitted: (t) {
                      if (t.trim().isNotEmpty) onSend(t);
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            if (canVoice)
              SizedBox(
                height: 48,
                width: 48,
                child: FloatingActionButton.small(
                  heroTag: '_mic_ai',
                  tooltip: 'Mic',
                  onPressed: () {
                    // Placeholder: replace with speech_to_text later
                    controller.text = "🎤 Listening...";
                  },
                  child: const Icon(Icons.mic_none),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AssistantBottomBar extends ConsumerWidget {
  const _AssistantBottomBar({required this.onScanMeal});
  final Future<void> Function() onScanMeal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomAppBar(
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              tooltip: 'Plan Day',
              icon: const Icon(Icons.checklist_rtl),
              onPressed: () => ref
                  .read(aiChatControllerProvider.notifier)
                  .sendText('Plan my day'),
            ),
            IconButton(
              tooltip: 'Tips',
              icon: const Icon(Icons.tips_and_updates_outlined),
              onPressed: () => ref
                  .read(aiChatControllerProvider.notifier)
                  .sendText('Give me personalized tips'),
            ),
            IconButton(
              tooltip: 'Mindfulness',
              icon: const Icon(Icons.self_improvement),
              onPressed: () => ref
                  .read(aiChatControllerProvider.notifier)
                  .sendText('Mindfulness exercises'),
            ),
            if (FeatureFlags.aiAssistantScanMeal)
              IconButton(
                tooltip: 'Scan Meal',
                icon: const Icon(Icons.document_scanner),
                onPressed: onScanMeal,
              ),
          ],
        ),
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
                'I can help you stay on track with your health goals.',
                style: t.bodyMedium?.copyWith(color: color),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _HintBullet(
                icon: Icons.fastfood_outlined,
                text:
                    'Scan your meals to estimate calories and nutrition values.',
                color: color,
              ),
              _HintBullet(
                icon: Icons.schedule_outlined,
                text: 'Plan your day with personalized routines and reminders.',
                color: color,
              ),
              _HintBullet(
                icon: Icons.tips_and_updates_outlined,
                text:
                    'Get actionable tips based on your activity, sleep, and goals.',
                color: color,
              ),
              _HintBullet(
                icon: Icons.self_improvement_outlined,
                text:
                    'Try quick mindfulness and breathing exercises to reset.',
                color: color,
              ),
              _HintBullet(
                icon: Icons.explore_outlined,
                text:
                    'Ask about foods, symptoms, workouts, hydration, and more.',
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                'Tap the mic to dictate or type your question below.',
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

