// lib/features/ai_assistant/application/providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/usecases/send_message_uc.dart';
import '../domain/usecases/suggest_actions_uc.dart';
import '../domain/usecases/route_intent_uc.dart';
import '../domain/repositories/assistant_repository.dart';
import '../domain/repositories/conversation_repository.dart';
import '../domain/repositories/memory_repository.dart';
import '../domain/entities/intent.dart';
import '../domain/entities/conversation.dart';
import '../infrastructure/data_sources/stubs/local_ai_client.dart';
import '../infrastructure/repositories/assistant_repository_impl.dart';
import '../infrastructure/repositories/conversation_repository_impl.dart';
import '../infrastructure/repositories/memory_repository_impl.dart';
import '../infrastructure/stt_tts/tts_bridge.dart';
import 'assistant_controller.dart';
import 'conversations_controller.dart';
import 'smart_actions_controller.dart';
import 'state/assistant_state.dart';

final localAiClientProvider = Provider((ref) => LocalAiClient());

final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  final client = ref.read(localAiClientProvider);
  return AssistantRepositoryImpl(client);
});

final conversationRepositoryProvider =
    Provider<ConversationRepository>((ref) => ConversationRepositoryImpl());

final memoryRepositoryProvider =
    Provider<MemoryRepository>((ref) => MemoryRepositoryImpl());

final sendMessageUseCaseProvider = Provider((ref) {
  final repo = ref.read(assistantRepositoryProvider);
  return SendMessageUseCase(repo);
});

final suggestActionsUseCaseProvider = Provider((ref) {
  final repo = ref.read(assistantRepositoryProvider);
  return SuggestActionsUseCase(repo);
});

final routeIntentUseCaseProvider = Provider((ref) {
  final repo = ref.read(assistantRepositoryProvider);
  return RouteIntentUseCase(repo);
});

final ttsBridgeProvider = Provider((ref) => TtsBridge());

final conversationsControllerProvider =
    StateNotifierProvider<ConversationsController, List<Conversation>>((ref) {
  final repo = ref.read(conversationRepositoryProvider);
  return ConversationsController(repo);
});

final assistantControllerProvider =
    StateNotifierProvider<AssistantController, AssistantState>((ref) {
  const conversationId = 'default';
  final send = ref.read(sendMessageUseCaseProvider);
  final suggest = ref.read(suggestActionsUseCaseProvider);
  final route = ref.read(routeIntentUseCaseProvider);
  final tts = ref.read(ttsBridgeProvider);
  return AssistantController(send, suggest, route, tts, conversationId);
});

final smartActionsControllerProvider =
    StateNotifierProvider<SmartActionsController, List<IntentType>>(
        (ref) => SmartActionsController());
