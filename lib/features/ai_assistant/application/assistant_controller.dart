// lib/features/ai_assistant/application/assistant_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../domain/entities/chat_message.dart';
import '../domain/entities/intent.dart';
import '../domain/usecases/send_message_uc.dart';
import '../domain/usecases/suggest_actions_uc.dart';
import '../domain/usecases/route_intent_uc.dart';
import '../infrastructure/stt_tts/tts_bridge.dart';
import 'state/assistant_state.dart';

class AssistantController extends StateNotifier<AssistantState> {
  AssistantController(
    this._sendMessage,
    this._suggestActions,
    this._routeIntent,
    this._tts,
    this._conversationId,
  ) : super(const AssistantState());

  final SendMessageUseCase _sendMessage;
  final SuggestActionsUseCase _suggestActions;
  final RouteIntentUseCase _routeIntent;
  final TtsBridge _tts;
  final String _conversationId;
  final _uuid = const Uuid();

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    final userMsg = ChatMessage(
      id: _uuid.v4(),
      conversationId: _conversationId,
      role: ChatRole.user,
      text: text,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      status: AssistantStatus.sending,
    );
    final reply = await _sendMessage(_conversationId, text);
    state = state.copyWith(
      messages: [...state.messages, reply],
      status: AssistantStatus.idle,
    );
    await _tts.speak(reply.text);
  }

  Future<void> handleIntent(Intent intent) async {
    await _routeIntent(intent);
  }

  Future<List<Intent>> refreshSuggestions() {
    return _suggestActions(_conversationId);
  }
}
