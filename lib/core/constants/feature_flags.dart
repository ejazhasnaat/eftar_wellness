class FeatureFlags {
  static const aiAssistantEnabled = true;
  static const aiSmartActionsEnabled = true;
  static const aiTtsEnabled = true; // text-to-speech via existing engine
  static const aiVoiceInputEnabled = false; // STT stubbed/offline
  static const aiMealIntelligenceEnabled = true;
  static const aiMentalFitnessEnabled = true;
  static const aiChallengesEnabled = true;
  static const aiLifestyleIntegrationEnabled = true;
  static const aiLongevityModeEnabled = true;
  static const bool aiAssistantVoice = true;
  static const bool aiAssistantScanMeal = true;
  static const bool community = true;
  static const bool commerce = false;

  // Phase 6–7 flags
  static const cloudSyncEnabled = false;       // master switch for sync engine
  static const supabaseRemoteEnabled = false;  // wire RemoteDataSource when true
  static const llmOnlineEnabled = false;       // cloud LLM coaching (cohort gated)
  static const visionOnlineEnabled = false;    // cloud vision (meals)
  static const sttOnlineEnabled = false;       // cloud STT
  static const ttsOnlineEnabled = false;       // cloud TTS
}
