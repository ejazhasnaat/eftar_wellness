// lib/features/ai_assistant/domain/usecases/stream_messages_uc.dart

import '../entities/chat_message.dart';
import '../repositories/conversation_repository.dart';

class StreamMessagesUseCase {
  StreamMessagesUseCase(this._repo);
  final ConversationRepository _repo;

  Stream<List<ChatMessage>> call(String conversationId) async* {
    yield await _repo.fetchMessages(conversationId);
  }
}
