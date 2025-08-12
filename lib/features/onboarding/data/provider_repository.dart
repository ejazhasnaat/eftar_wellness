// lib/features/onboarding/data/provider_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderRepository {
  ProviderRepository(this._client);
  final SupabaseClient _client;

  Future<Map<String, dynamic>?> getProviderByCurrentUser() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await _client
        .from('food_providers')
        .select()
        .eq('user_id', uid)
        .maybeSingle();
    return row;
  }

  Future<void> upsertProviderForCurrentUser({
    required String name,
    required int deliveryRangeKm,
    required String? city,
    required String? country,
  }) async {
    final uid = _client.auth.currentUser!.id;

    final existing = await getProviderByCurrentUser();
    if (existing == null) {
      await _client.from('food_providers').insert({
        'user_id': uid,
        'name': name,
        'delivery_range_km': deliveryRangeKm,
        'city': city,
        'country': country,
        // approval_status defaults to 'pending'
      });
    } else {
      await _client.from('food_providers').update({
        'name': name,
        'delivery_range_km': deliveryRangeKm,
        'city': city,
        'country': country,
      }).eq('id', existing['id']);
    }
  }
}

