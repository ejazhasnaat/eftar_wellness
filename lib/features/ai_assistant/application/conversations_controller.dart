// lib/features/ai_assistant/application/conversations_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/conversation.dart';
import '../domain/repositories/conversation_repository.dart';

class ConversationsController extends StateNotifier<List<Conversation>> {
  ConversationsController(this._repo) : super(const []);

  final ConversationRepository _repo;

  Future<Conversation> startConversation(String title) async {
    final convo = await _repo.createConversation(title);
    state = [...state, convo];
    return convo;
  }
}
