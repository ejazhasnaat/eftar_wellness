import 'package:supabase_flutter/supabase_flutter.dart';

class ChallengeRepo {
  final _sb = Supabase.instance.client;

  Future<List<Map<String,dynamic>>> active() async =>
      (await _sb.from('challenges').select('*').eq('is_active', true)).cast<Map<String,dynamic>>();

  Future<void> join(String challengeId) async {
    final uid = _sb.auth.currentUser!.id;
    await _sb.from('challenge_participants').insert({'challenge_id': challengeId, 'user_id': uid});
  }

  Future<void> checkIn(String challengeId, DateTime day) async {
    final uid = _sb.auth.currentUser!.id;
    await _sb.from('challenge_checkins').upsert({
      'challenge_id': challengeId,
      'user_id': uid,
      'checkin_date': day.toIso8601String().substring(0,10),
    }, onConflict: 'challenge_id,user_id,checkin_date');
  }

  Future<List<Map<String,dynamic>>> leaderboard(String challengeId) async =>
      (await _sb.from('v_challenge_leaderboard').select('*').eq('challenge_id', challengeId)
        .order('rnk')).cast<Map<String,dynamic>>();
}
