// lib/features/ai_assistant/application/ai_chat_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eftar_wellness/features/ai_assistant/domain/ai_message.dart';
import 'package:eftar_wellness/features/ai_assistant/domain/ai_assistant_repository.dart';
import 'package:eftar_wellness/features/ai_assistant/data/ai_assistant_repository_local.dart';

/// DI for the AI Assistant repository (local by default; swappable later).
final aiAssistantRepositoryProvider = Provider<AiAssistantRepository>((ref) {
  return AiAssistantRepositoryLocal();
});

/// Chat controller managing the conversation state.
final aiChatControllerProvider =
    StateNotifierProvider<AiChatController, List<AiMessage>>((ref) {
  final repo = ref.read(aiAssistantRepositoryProvider);
  return AiChatController(repo)..loadHistory();
});

class AiChatController extends StateNotifier<List<AiMessage>> {
  AiChatController(this._repo) : super(const []);

  final AiAssistantRepository _repo;

  void loadHistory() {
    state = List.of(_repo.history);
  }

  Future<void> sendText(String message) async {
    if (message.trim().isEmpty) return;
    // Optimistic user message for responsive UI
    state = [...state, AiMessage(content: message, isUser: true)];
    final reply = await _repo.sendText(message);
    state = [...state, AiMessage(content: reply, isUser: false)];
  }

  Future<void> sendVoice() async {
    final reply = await _repo.sendVoice();
    state = [...state, AiMessage(content: reply, isUser: false)];
  }

  Future<void> analyzeMeal() async {
    final reply = await _repo.analyzeMealPhoto();
    state = [...state, AiMessage(content: reply, isUser: false)];
  }

  void clearChat() {
    state = const [];
  }
}
