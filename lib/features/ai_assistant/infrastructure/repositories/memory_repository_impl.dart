// lib/features/ai_assistant/infrastructure/repositories/memory_repository_impl.dart

import '../../domain/entities/memory_snippet.dart';
import '../../domain/repositories/memory_repository.dart';

class MemoryRepositoryImpl implements MemoryRepository {
  final _memories = <MemorySnippet>[];

  @override
  Future<void> saveMemory(MemorySnippet snippet) async {
    _memories.add(snippet);
  }

  @override
  Future<List<MemorySnippet>> listMemories() async => List.unmodifiable(_memories);
}
