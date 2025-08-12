import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceIO {
  final stt.SpeechToText _stt = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  Future<String?> recordOnce() async {
    final available = await _stt.initialize();
    if (!available) return null;
    String? captured;
    await _stt.listen(onResult: (r) { if (r.finalResult) captured = r.recognizedWords; }, listenFor: const Duration(seconds: 8));
    await Future.delayed(const Duration(seconds: 8));
    await _stt.stop();
    return (captured == null || captured!.isEmpty) ? null : captured;
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }
}
