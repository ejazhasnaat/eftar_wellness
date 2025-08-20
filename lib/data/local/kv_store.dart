import 'package:shared_preferences/shared_preferences.dart';

class KvStore {
  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<void> putBool(String key, bool value) async {
    final p = await _prefs();
    await p.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    final p = await _prefs();
    return p.getBool(key);
  }

  Future<void> putString(String key, String value) async {
    final p = await _prefs();
    await p.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final p = await _prefs();
    return p.getString(key);
  }

  Future<void> putInt(String key, int value) async {
    final p = await _prefs();
    await p.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    final p = await _prefs();
    return p.getInt(key);
  }

  Future<void> remove(String key) async {
    final p = await _prefs();
    await p.remove(key);
  }
}
