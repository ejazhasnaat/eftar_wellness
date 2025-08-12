// lib/features/onboarding/data/expert_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpertRepository {
  ExpertRepository(this._client);
  final SupabaseClient _client;

  Future<Map<String, dynamic>?> getExpertByCurrentUser() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await _client
        .from('experts')
        .select()
        .eq('user_id', uid)
        .maybeSingle();
    return row;
  }

  Future<void> upsertExpertForCurrentUser({
    required String expertType, // 'dietitian' or 'fitness_expert'
    required String bio,
    required int experienceYears,
    required num? ratePerAppointment,
    required Map<String, dynamic> availability, // JSON
    required String? city,
    required String? country,
  }) async {
    final uid = _client.auth.currentUser!.id;

    // If a row exists, update; else insert.
    final existing = await getExpertByCurrentUser();
    if (existing == null) {
      await _client.from('experts').insert({
        'user_id': uid,
        'expert_type': expertType,
        'bio': bio,
        'experience_years': experienceYears,
        'rate_per_appointment': ratePerAppointment,
        'availability': availability,
        'city': city,
        'country': country,
        // approval_status defaults to 'pending' server-side
      });
    } else {
      await _client.from('experts').update({
        'expert_type': expertType,
        'bio': bio,
        'experience_years': experienceYears,
        'rate_per_appointment': ratePerAppointment,
        'availability': availability,
        'city': city,
        'country': country,
      }).eq('id', existing['id']);
    }
  }
}

