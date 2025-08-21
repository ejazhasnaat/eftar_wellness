// lib/features/ai_assistant/domain/entities/conversation.dart

class Conversation {
  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.stats = const {},
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> stats;
}
