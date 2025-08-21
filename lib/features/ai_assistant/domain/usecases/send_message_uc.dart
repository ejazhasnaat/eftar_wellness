// lib/features/ai_assistant/domain/usecases/send_message_uc.dart

import '../entities/chat_message.dart';
import '../repositories/assistant_repository.dart';

class SendMessageUseCase {
  SendMessageUseCase(this._repo);
  final AssistantRepository _repo;

  Future<ChatMessage> call(String conversationId, String text) {
    return _repo.ask(conversationId, text);
  }
}
