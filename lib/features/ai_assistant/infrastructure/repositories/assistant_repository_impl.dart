// lib/features/ai_assistant/infrastructure/repositories/assistant_repository_impl.dart

import 'package:uuid/uuid.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/intent.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../data_sources/stubs/local_ai_client.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  AssistantRepositoryImpl(this._client);

  final LocalAiClient _client;
  final _uuid = const Uuid();

  @override
  Future<ChatMessage> ask(String conversationId, String text) async {
    final replyText = _client.reply(text);
    return ChatMessage(
      id: _uuid.v4(),
      conversationId: conversationId,
      role: ChatRole.assistant,
      text: replyText,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<List<Intent>> suggestActions(String conversationId) async {
    // Without conversation context just return empty for now
    return [];
  }

  @override
  Future<void> routeIntent(Intent intent) async {
    // Local actions would be handled here. Currently a no-op.
  }
}
