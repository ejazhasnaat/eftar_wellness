import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/role.dart';

class ProfileRepository {
  ProfileRepository(this._client);
  final SupabaseClient _client;

  Future<Map<String, dynamic>?> getProfile() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final resp = await _client.from('profiles').select().eq('id', uid).maybeSingle();
    return resp;
  }

  Future<void> upsertProfile({
    required String fullName,
    required UserRole role,
    String? city,
    String? country,
  }) async {
    final uid = _client.auth.currentUser!.id;
    await _client.from('profiles').upsert({
      'id': uid,
      'full_name': fullName,
      'role': roleToString(role),
      'city': city,
      'country': country,
    });
  }

  Future<UserRole> ensureRoleDefault() async {
    final p = await getProfile();
    return roleFromString(p?['role'] as String?);
  }
}
