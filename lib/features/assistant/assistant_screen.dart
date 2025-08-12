// lib/features/assistant/assistant_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // <-- NEW
import '../../core/feature_gate.dart';
import '../../ui/gating/gated_builder.dart';
import 'assistant_controller.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});
  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final gate = ref.read(featureGateProvider);
    final state = ref.watch(assistantControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Health Assistant')),
      body: Column(children: [
        const Expanded(child: SizedBox()),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                decoration:
                    const InputDecoration(hintText: 'Type your message...'),
              ),
            ),
            const SizedBox(width: 8),
            GatedBuilder(
              check: () async {
                await gate.refresh();
                return gate.canUseAssistant();
              },
              onAllowed: () async {
                final sent = await ref
                    .read(assistantControllerProvider.notifier)
                    .trySendMessage(_ctrl.text);
                if (!sent && mounted) {
                  // If somehow blocked here, also push paywall.
                  context.push('/paywall'
                      '?h=You%20reached%20the%20free%20limit'
                      '&b=Upgrade%20to%20unlock%20unlimited%20assistant%20chats.'
                      '&cta=https%3A%2F%2Fyour-checkout-link');
                } else {
                  _ctrl.clear();
                }
              },
              onBlocked: (rem) {
                // Redirect to full-screen paywall
                context.push('/paywall'
                    '?h=You%20reached%20the%20free%20limit'
                    '&b=Upgrade%20to%20unlock%20unlimited%20assistant%20chats.'
                    '&cta=https%3A%2F%2Fyour-checkout-link');
                // Return a placeholder widget (not shown since we navigated)
                return const SizedBox.shrink();
              },
              child: FilledButton(
                onPressed: null,
                child: state.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

