// lib/features/ai_assistant/domain/repositories/conversation_repository.dart

import '../entities/chat_message.dart';
import '../entities/conversation.dart';

abstract class ConversationRepository {
  Future<Conversation> createConversation(String title);
  Future<List<ChatMessage>> fetchMessages(String conversationId, {int limit = 20, int offset = 0});
  Future<void> addMessage(ChatMessage message);
}
