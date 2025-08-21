// lib/features/ai_assistant/infrastructure/stt_tts/stt_client_stub.dart

abstract class SttClient {
  Future<String> transcribe();
}

class SttClientStub implements SttClient {
  @override
  Future<String> transcribe() async => '';
}
