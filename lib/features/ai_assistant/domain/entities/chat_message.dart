// lib/features/ai_assistant/domain/entities/chat_message.dart

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.text,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.metadata,
  });

  final String id;
  final String conversationId;
  final ChatRole role;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;
  final Map<String, dynamic>? metadata;
}

enum ChatRole { user, assistant, system }

enum MessageStatus { sending, sent, error }
