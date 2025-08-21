// lib/features/ai_assistant/domain/repositories/assistant_repository.dart

import '../entities/chat_message.dart';
import '../entities/intent.dart';

abstract class AssistantRepository {
  Future<ChatMessage> ask(String conversationId, String text);
  Future<List<Intent>> suggestActions(String conversationId);
  Future<void> routeIntent(Intent intent);
}
