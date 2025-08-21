// lib/features/ai_assistant/infrastructure/stt_tts/tts_bridge.dart

class TtsBridge {
  Future<void> speak(String text) async {
    // In a real implementation, this would call the platform TTS engine.
    // ignore: avoid_print
    print('TTS: $text');
  }
}
