// lib/features/ai_assistant/domain/entities/intent.dart

enum IntentType {
  logMeal,
  logWater,
  startRun,
  logMood,
  meditation,
  joinChallenge,
  settings,
}

class Intent {
  Intent(this.type, {this.payload});
  final IntentType type;
  final Map<String, dynamic>? payload;
}
