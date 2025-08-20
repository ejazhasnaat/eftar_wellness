// lib/features/ai_assistant/data/ai_assistant_repository_local.dart
import 'package:eftar_wellness/features/ai_assistant/domain/ai_message.dart';
import 'package:eftar_wellness/features/ai_assistant/domain/ai_assistant_repository.dart';

/// Local, in-memory implementation (non-breaking). Can be replaced later.
class AiAssistantRepositoryLocal implements AiAssistantRepository {
  final List<AiMessage> _history = [];

  @override
  Future<String> sendText(String message) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _history.add(AiMessage(content: message, isUser: true));
    final reply = 'Echo: $message';
    _history.add(AiMessage(content: reply, isUser: false));
    return reply;
  }

  @override
  Future<String> sendVoice() async {
    await Future.delayed(const Duration(milliseconds: 200));
    const transcribed = 'voice: hello assistant';
    _history.add(const AiMessage(content: transcribed, isUser: true));
    const reply = 'Echo: $transcribed';
    _history.add(const AiMessage(content: reply, isUser: false));
    return reply;
  }

  @override
  Future<String> analyzeMealPhoto() async {
    await Future.delayed(const Duration(milliseconds: 200));
    const reply = 'Estimated nutrition: 500 kcal, 30g protein, 20g fat, 50g carbs.';
    _history.add(const AiMessage(content: reply, isUser: false));
    return reply;
  }

  @override
  List<AiMessage> get history => List.unmodifiable(_history);
}
