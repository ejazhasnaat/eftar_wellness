// lib/features/ai_assistant/domain/entities/assistant_settings.dart

class AssistantSettings {
  const AssistantSettings({
    this.ttsOn = false,
    this.pinnedActions = const [],
    this.coachMode = 'off',
    this.tone = 'encouraging',
  });

  final bool ttsOn;
  final List<String> pinnedActions;
  final String coachMode;
  final String tone;

  AssistantSettings copyWith({
    bool? ttsOn,
    List<String>? pinnedActions,
    String? coachMode,
    String? tone,
  }) {
    return AssistantSettings(
      ttsOn: ttsOn ?? this.ttsOn,
      pinnedActions: pinnedActions ?? this.pinnedActions,
      coachMode: coachMode ?? this.coachMode,
      tone: tone ?? this.tone,
    );
  }
}
