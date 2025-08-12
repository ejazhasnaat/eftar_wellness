import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';

class UsageRepo {
  final _sb = Supabase.instance.client;

  Future<int> currentMonthCount(String kind) async {
    final uid = _sb.auth.currentUser!.id;
    final startOfMonth =
        DateTime(DateTime.now().year, DateTime.now().month, 1).toIso8601String();
    final rows = await _sb
        .from('usage_counters')
        .select('count')
        .eq('user_id', uid)
        .eq('kind', kind)
        .gte('period_start', startOfMonth)
        .limit(1);
    if (rows.isEmpty) return 0;
    return (rows.first['count'] as num).toInt();
  }

  Future<int> increment(String kind, {int by = 1}) async {
    final uid = _sb.auth.currentUser!.id;
    final periodStart = DateTime(DateTime.now().year, DateTime.now().month, 1)
        .toIso8601String();
    final rows = await _sb
        .from('usage_counters')
        .upsert({
          'user_id': uid,
          'kind': kind,
          'period_start': periodStart.substring(0, 10),
          'count': 0,
        }, onConflict: 'user_id,kind,period_start')
        .select()
        .limit(1);
    final current = (rows.first['count'] as num).toInt();
    final updated = current + by;
    await _sb
        .from('usage_counters')
        .update({'count': updated})
        .match({
          'user_id': uid,
          'kind': kind,
          'period_start': periodStart.substring(0, 10),
        });
    return updated;
  }

  Future<(bool allowed, int remaining)> canUseAssistant({required bool isPremium}) async {
    if (isPremium) return (true, 9999);
    final used = await currentMonthCount('assistant_turn');
    final rem = Plans.freeTurnsPerMonth - used;
    return (rem > 0, rem.clamp(0, Plans.freeTurnsPerMonth));
  }

  Future<(bool allowed, int remaining)> canBookFreeAppointment({required bool isPremium}) async {
    if (isPremium) return (true, 9999);
    final used = await currentMonthCount('free_appointment');
    final rem = Plans.freeAppointmentsPerMonth - used;
    return (rem > 0, rem.clamp(0, Plans.freeAppointmentsPerMonth));
  }
}
