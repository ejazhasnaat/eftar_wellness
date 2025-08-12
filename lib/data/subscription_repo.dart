import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/subscription.dart';

class SubscriptionRepo {
  final _sb = Supabase.instance.client;

  Future<Subscription?> current() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return null;
    final rows = await _sb
        .from('subscriptions')
        .select('*')
        .eq('user_id', uid)
        .eq('status', 'active')
        .order('start_date', ascending: false)
        .limit(1);
    if (rows.isEmpty) return null;
    return Subscription.fromMap(rows.first);
  }

  Future<bool> isPremium() async {
    final uid = _sb.auth.currentUser!.id;
    final r = await _sb.rpc('is_premium', params: {'uid': uid});
    if (r is bool) return r;
    final sub = await current();
    return sub?.isActive ?? false;
  }
}
