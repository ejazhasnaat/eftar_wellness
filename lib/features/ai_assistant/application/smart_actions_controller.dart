// lib/features/ai_assistant/application/smart_actions_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/intent.dart';

class SmartActionsController extends StateNotifier<List<IntentType>> {
  SmartActionsController() : super(_defaultPinned);

  static const _defaultPinned = [
    IntentType.logMeal,
    IntentType.logWater,
    IntentType.startRun,
    IntentType.logMood,
    IntentType.meditation,
    IntentType.joinChallenge,
    IntentType.settings,
  ];

  void pin(IntentType intent) {
    if (!state.contains(intent)) {
      state = [...state, intent];
    }
  }

  void unpin(IntentType intent) {
    state = state.where((i) => i != intent).toList();
  }
}
