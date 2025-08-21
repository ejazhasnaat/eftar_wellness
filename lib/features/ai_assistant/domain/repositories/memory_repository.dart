// lib/features/ai_assistant/domain/repositories/memory_repository.dart

import '../entities/memory_snippet.dart';

abstract class MemoryRepository {
  Future<void> saveMemory(MemorySnippet snippet);
  Future<List<MemorySnippet>> listMemories();
}
