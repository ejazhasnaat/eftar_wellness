// lib/features/ai_assistant/domain/entities/memory_snippet.dart

class MemorySnippet {
  MemorySnippet({
    required this.id,
    required this.summary,
    required this.createdAt,
    this.ttl,
  });

  final String id;
  final String summary;
  final DateTime createdAt;
  final Duration? ttl;
}
