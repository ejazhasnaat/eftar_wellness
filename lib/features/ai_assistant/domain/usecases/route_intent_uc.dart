// lib/features/ai_assistant/domain/usecases/route_intent_uc.dart

import '../entities/intent.dart';
import '../repositories/assistant_repository.dart';

class RouteIntentUseCase {
  RouteIntentUseCase(this._repo);
  final AssistantRepository _repo;

  Future<void> call(Intent intent) {
    return _repo.routeIntent(intent);
  }
}
