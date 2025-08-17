import '../domain/ai_message.dart';

class AiAssistantRepository {
  final List<AiMessage> _history = [];

  Future<String> sendText(String message) async {
    // Placeholder for backend API call
    await Future.delayed(const Duration(milliseconds: 300));
    _history.add(AiMessage(content: message, isUser: true));
    final reply = 'Echo: ' + message;
    _history.add(AiMessage(content: reply, isUser: false));
    return reply;
  }

  Future<String> sendVoice() async {
    // Placeholder for processing voice input (STT -> text -> response)
    await Future.delayed(const Duration(milliseconds: 300));
    const voiceReply = 'Voice input received (placeholder).';
    _history.add(const AiMessage(content: voiceReply, isUser: false));
    return voiceReply;
  }

  Future<String> analyzeMealPhoto() async {
    // Placeholder: would call ML service for meal analysis
    await Future.delayed(const Duration(milliseconds: 300));
    const reply =
        'Estimated nutrition: 500 kcal, 30g protein, 20g fat, 50g carbs.';
    _history.add(const AiMessage(content: reply, isUser: false));
    return reply;
  }

  List<AiMessage> get history => List.unmodifiable(_history);
}
