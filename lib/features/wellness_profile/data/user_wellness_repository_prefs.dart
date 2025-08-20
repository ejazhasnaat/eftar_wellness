import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';
import '../domain/repository.dart'; // ⬅️ use domain contract

const _kProfileV2 = 'user_wellness_profile_v2';

class UserWellnessRepositoryPrefs implements UserWellnessRepository {
  @override
  Future<UserWellnessProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProfileV2);
    if (raw == null) return const UserWellnessProfile();
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserWellnessProfile.fromJson(map);
    } catch (_) {
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

