// lib/features/ai_assistant/infrastructure/repositories/conversation_repository_impl.dart

import 'package:uuid/uuid.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/conversation_repository.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final _uuid = const Uuid();
  final Map<String, Conversation> _conversations = {};
  final Map<String, List<ChatMessage>> _messages = {};

  @override
  Future<Conversation> createConversation(String title) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final convo = Conversation(id: id, title: title, createdAt: now, updatedAt: now);
    _conversations[id] = convo;
    _messages[id] = [];
    return convo;
  }

  @override
  Future<void> addMessage(ChatMessage message) async {
    _messages.putIfAbsent(message.conversationId, () => []);
    _messages[message.conversationId]!.add(message);
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String conversationId, {int limit = 20, int offset = 0}) async {
    final list = _messages[conversationId] ?? [];
    return list.skip(offset).take(limit).toList();
  }
}
