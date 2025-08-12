import 'package:supabase_flutter/supabase_flutter.dart';

class ConversationRepo {
  final _sb = Supabase.instance.client;

  Future<String> ensureConversation(List<String> participants) async {
    final rows = await _sb
        .from('conversations')
        .select('id,participants')
        .contains('participants', participants)
        .limit(1);
    if (rows.isNotEmpty) return rows.first['id'];
    final inserted = await _sb.from('conversations')
        .insert({'participants': participants}).select('id').single();
    return inserted['id'];
  }

  Stream<List<Map<String,dynamic>>> streamMessages(String conversationId) {
    return _sb.from('messages').stream(primaryKey: ['id'])
      .eq('conversation_id', conversationId)
      .order('created_at')
      .map((rows) => rows.cast<Map<String,dynamic>>());
  }

  Future<void> send(String conversationId, String text) async {
    final uid = _sb.auth.currentUser!.id;
    await _sb.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': uid,
      'body': text,
    });
  }
}
