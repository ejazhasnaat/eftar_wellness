// lib/features/ai_assistant/presentation/widgets/smart_action_chips.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/intent.dart' as ai;
import '../../application/providers.dart';

class SmartActionChips extends ConsumerWidget {
  const SmartActionChips({super.key, required this.onSelected});

  final void Function(ai.IntentType intent) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.watch(smartActionsControllerProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          for (final intent in actions)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ActionChip(
                label: Text(_labelFor(intent)),
                onPressed: () => onSelected(intent),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ActionChip(
              label: const Text('+'),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }

  String _labelFor(ai.IntentType intent) {
    switch (intent) {
      case ai.IntentType.logMeal:
        return '🍽 Meal Intelligence';
      case ai.IntentType.logWater:
        return '💧 Log Water';
      case ai.IntentType.startRun:
        return '🏃 Start Run';
      case ai.IntentType.logMood:
        return '🙂 Log Mood';
      case ai.IntentType.meditation:
        return '🧘 Quick Meditation';
      case ai.IntentType.joinChallenge:
        return '🏆 Join Challenge';
      case ai.IntentType.settings:
        return '⚙️ Settings';
    }
  }
}
