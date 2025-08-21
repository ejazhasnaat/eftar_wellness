// lib/features/ai_assistant/infrastructure/data_sources/stubs/local_ai_client.dart

import '../../../domain/entities/intent.dart';

/// A tiny deterministic rules engine that responds to keywords.
class LocalAiClient {
  String reply(String text) {
    final l = text.toLowerCase();
    if (l.contains('water')) {
      return 'Remember to stay hydrated. Shall I log a glass of water?';
    }
    if (l.contains('run')) {
      return 'Great! Ready to start your run.';
    }
    if (l.contains('stress') || l.contains('anxious')) {
      return 'Let\'s take a deep breath together.';
    }
    return "I'm here to help with your wellness goals.";
  }

  List<IntentType> suggestedIntents(String text) {
    final l = text.toLowerCase();
    final intents = <IntentType>[];
    if (l.contains('water')) intents.add(IntentType.logWater);
    if (l.contains('run')) intents.add(IntentType.startRun);
    if (l.contains('stress') || l.contains('anxious')) {
      intents.add(IntentType.meditation);
      intents.add(IntentType.logMood);
    }
    return intents;
  }
}
