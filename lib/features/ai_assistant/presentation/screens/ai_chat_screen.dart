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
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final m = messages[index];
                return Align(
                  alignment:
                      m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: m.isUser
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceVariant,
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
              if (text.trim().isEmpty) return;
              await controller.sendText(text);
              _textController.clear();
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent + 60,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: _AssistantBottomBar(onScanMeal: controller.analyzeMeal),
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
              child: TextField(
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
                    onPressed: () => onSend(controller.text),
                    icon: Icon(Icons.send, color: cs.onSurfaceVariant),
                  ),
                ),
                onSubmitted: onSend,
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
              onPressed: () =>
                  ref.read(aiChatControllerProvider.notifier).sendText('Plan my day'),
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

