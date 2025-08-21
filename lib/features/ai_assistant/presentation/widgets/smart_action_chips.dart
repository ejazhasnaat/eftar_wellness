// lib/features/ai_assistant/presentation/widgets/smart_action_chips.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/intent.dart';
import '../../application/providers.dart';

class SmartActionChips extends ConsumerWidget {
  const SmartActionChips({super.key, required this.onSelected});

  final void Function(IntentType intent) onSelected;

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

  String _labelFor(IntentType intent) {
    switch (intent) {
      case IntentType.logMeal:
        return '🍽 Meal Intelligence';
      case IntentType.logWater:
        return '💧 Log Water';
      case IntentType.startRun:
        return '🏃 Start Run';
      case IntentType.logMood:
        return '🙂 Log Mood';
      case IntentType.meditation:
        return '🧘 Quick Meditation';
      case IntentType.joinChallenge:
        return '🏆 Join Challenge';
      case IntentType.settings:
        return '⚙️ Settings';
    }
  }
}
