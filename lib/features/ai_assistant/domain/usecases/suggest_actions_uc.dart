// lib/features/ai_assistant/domain/usecases/suggest_actions_uc.dart

import '../entities/intent.dart';
import '../repositories/assistant_repository.dart';

class SuggestActionsUseCase {
  SuggestActionsUseCase(this._repo);
  final AssistantRepository _repo;

  Future<List<Intent>> call(String conversationId) {
    return _repo.suggestActions(conversationId);
  }
}
