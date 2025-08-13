import 'package:shared_preferences/shared_preferences.dart';

class KvStore {
  Future<void> putBool(String key, bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(key);
  }
}
