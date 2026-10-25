// Read aloud (UIC-NAV-03): the device's own text-to-speech, behind an app interface.
//
// Best effort (bull DR-015): the app uses voices installed on the device, prefers
// voices that work offline, and never sends text to a cloud service. When the
// language has no voice it says so; it never reads in a substitute language.
import 'package:flutter_tts/flutter_tts.dart';

enum SpeechAvailability { available, noVoice, noEngine }

abstract class SpeechService {
  Future<SpeechAvailability> prepare(String lang);

  /// Speaks [text] and completes when it has been spoken (or stopped).
  Future<void> speak(String text, {required double rate});

  Future<void> stop();
}

const _locales = {
  'en': ['en-GB', 'en-US', 'en'],
  'ro': ['ro-RO', 'ro'],
  'fr': ['fr-FR', 'fr'],
  'de': ['de-DE', 'de'],
};

class DeviceSpeech implements SpeechService {
  final _tts = FlutterTts();
  bool _configured = false;

  @override
  Future<SpeechAvailability> prepare(String lang) async {
    try {
      if (!_configured) {
        await _tts.awaitSpeakCompletion(true);
        _configured = true;
      }
      for (final locale in _locales[lang] ?? [lang]) {
        final ok = await _tts.isLanguageAvailable(locale);
        if (ok != true) continue;
        await _tts.setLanguage(locale);
        await _preferOfflineVoice(locale);
        return SpeechAvailability.available;
      }
      return SpeechAvailability.noVoice;
    } on Object {
      return SpeechAvailability.noEngine;
    }
  }

  Future<void> _preferOfflineVoice(String locale) async {
    final voices = await _tts.getVoices;
    if (voices is! List) return;
    final prefix = locale.split('-').first.toLowerCase();
    for (final v in voices.whereType<Map>()) {
      final vLocale = '${v['locale']}'.toLowerCase();
      final network = '${v['network_required'] ?? v['networkConnectionRequired']}';
      if (vLocale.startsWith(prefix) && (network == '0' || network == 'false')) {
        await _tts.setVoice({'name': '${v['name']}', 'locale': '${v['locale']}'});
        return;
      }
    }
  }

  @override
  Future<void> speak(String text, {required double rate}) async {
    await _tts.setSpeechRate(rate);
    await _tts.speak(text);
  }

  @override
  Future<void> stop() => _tts.stop();
}
