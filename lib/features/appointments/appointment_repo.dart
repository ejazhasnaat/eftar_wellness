import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentRepo {
  final _sb = Supabase.instance.client;

  Future<Map<String, dynamic>> book({
    required String expertUserId,
    required String kind, // 'text'|'voice'|'video'
    required DateTime when,
    int durationMin = 20,
    bool freeIfAvailable = true,
  }) async {
    final row = await _sb.from('appointments').insert({
      'user_id': _sb.auth.currentUser!.id,
      'expert_id': expertUserId,
      'kind': kind,
      'scheduled_at': when.toIso8601String(),
      'duration_min': durationMin.clamp(1, 20),
      'paid_via': freeIfAvailable ? 'free_quota' : null,
    }).select().single();
    return row;
  }
}
