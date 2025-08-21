// lib/features/ai_assistant/infrastructure/data_sources/prefs/assistant_prefs.dart

import 'package:shared_preferences/shared_preferences.dart';

class AssistantPrefs {
  AssistantPrefs(this._prefs);

  final SharedPreferences _prefs;

  static const _ttsKey = 'assistant_tts_on';
  static const _pinnedKey = 'assistant_pinned_actions';

  bool get ttsOn => _prefs.getBool(_ttsKey) ?? false;
  Future<void> setTtsOn(bool value) => _prefs.setBool(_ttsKey, value);

  List<String> get pinnedActions => _prefs.getStringList(_pinnedKey) ?? const [];
  Future<void> setPinnedActions(List<String> actions) =>
      _prefs.setStringList(_pinnedKey, actions);
}
