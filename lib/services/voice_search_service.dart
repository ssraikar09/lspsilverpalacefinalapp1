import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceSearchService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      return false;
    }

    _isInitialized = await _speechToText.initialize(
      onError: (val) => debugPrint('onSpeechError: ${val.errorMsg}'),
      onStatus: (val) => debugPrint('onSpeechStatus: $val'),
    );
    return _isInitialized;
  }

  Future<void> startListening(Function(String, bool) onResult) async {
    if (!_isInitialized) {
      bool init = await initialize();
      if (!init) return;
    }
    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      ),
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  bool get isListening => _speechToText.isListening;
}
