// lib/features/ai_assistant/application/state/assistant_state.dart

import '../../domain/entities/chat_message.dart';

enum AssistantStatus { idle, sending, streaming, error }

class AssistantState {
  const AssistantState({
    this.messages = const [],
    this.status = AssistantStatus.idle,
  });

  final List<ChatMessage> messages;
  final AssistantStatus status;

  AssistantState copyWith({
    List<ChatMessage>? messages,
    AssistantStatus? status,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
    );
  }
}
