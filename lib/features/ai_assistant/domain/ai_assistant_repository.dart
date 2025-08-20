// lib/features/ai_assistant/domain/ai_assistant_repository.dart
import 'ai_message.dart';

abstract class AiAssistantRepository {
  Future<String> sendText(String message);
  Future<String> sendVoice();
  Future<String> analyzeMealPhoto();

  List<AiMessage> get history;
}
