import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/ai_message.dart';
import '../data/ai_assistant_repository.dart';

final aiChatControllerProvider =
    StateNotifierProvider<AiChatController, List<AiMessage>>((ref) {
  final repo = AiAssistantRepository();
  return AiChatController(repo);
});

class AiChatController extends StateNotifier<List<AiMessage>> {
  AiChatController(this._repo) : super(const []);

  final AiAssistantRepository _repo;

  Future<void> sendText(String text) async {
    if (text.trim().isEmpty) return;
    state = [...state, AiMessage(content: text, isUser: true)];
    final reply = await _repo.sendText(text);
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
