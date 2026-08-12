import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._internal();
  static final TtsService instance = TtsService._internal();

  late final FlutterTts _flutterTts;
  bool _initialized = false;

  VoidCallback? onStart;
  VoidCallback? onComplete;
  Function(String)? onError;

  Future<void> init({String locale = 'hi-IN'}) async {
    if (_initialized) return;
    _flutterTts = FlutterTts();

    try {
      await _flutterTts.setLanguage(locale);
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        if (onStart != null) onStart!();
      });

      _flutterTts.setCompletionHandler(() {
        if (onComplete != null) onComplete!();
      });

      _flutterTts.setErrorHandler((msg) {
        if (onError != null) onError!(msg ?? 'Unknown TTS error');
      });

      _initialized = true;
    } catch (e) {
      if (kDebugMode) print('TTS init error: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!_initialized) await init();
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    if (!_initialized) return;
    await _flutterTts.stop();
  }

  Future<void> pause() async {
    if (!_initialized) return;
    // Not all platforms implement pause; fall back to stop
    try {
      await _flutterTts.pause();
    } catch (_) {
      await stop();
    }
  }

  Future<void> setHandlers({VoidCallback? onStart, VoidCallback? onComplete, Function(String)? onError}) async {
    this.onStart = onStart;
    this.onComplete = onComplete;
    this.onError = onError;
  }
}
