import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';

const _kProfileV2 = 'user_wellness_profile_v2';

/// Simple local repository backed by SharedPreferences.
/// Safe to swap to Supabase later.
abstract class UserWellnessRepository {
  Future<UserWellnessProfile> load();
  Future<void> save(UserWellnessProfile profile);
}

class UserWellnessRepositoryPrefs implements UserWellnessRepository {
  @override
  Future<UserWellnessProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_kProfileV2);
    if (jsonStr == null || jsonStr.isEmpty) {
      return const UserWellnessProfile();
    }
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserWellnessProfile.fromJson(map);
    } catch (_) {
      // If corrupted, reset gracefully
      return const UserWellnessProfile();
    }
  }

  @override
  Future<void> save(UserWellnessProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(profile.toJson());
    await prefs.setString(_kProfileV2, jsonStr);
  }
}

