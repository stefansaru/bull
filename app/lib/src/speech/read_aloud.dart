// The read-aloud session: which artefact, which unit is being spoken (highlighted on
// the page), and paragraph stepping. It lives above the shell, so rotation and
// relayout do not interrupt it.
import 'package:flutter/widgets.dart';

import '../content/book.dart';
import '../content/inline.dart';
import 'speech_service.dart';

/// One spoken stretch, tied to the unit it comes from.
class SpeechPart {
  const SpeechPart(this.uid, this.text);
  final String uid;
  final String text;
}

/// Reading order (UIC-NAV-03): date line, title, then the body in order, captions
/// included. Links are read as their labels.
List<SpeechPart> speechParts(Artefact a, String lang) {
  final parts = <SpeechPart>[
    if (a.year.isNotEmpty) SpeechPart('', a.year),
    SpeechPart('', pick(a.title, lang)),
  ];
  for (final u in a.units) {
    final caption = plainLinks(pick(u.caption, lang));
    if (caption.isNotEmpty) parts.add(SpeechPart(u.uid, caption));
    for (final p in plainLinks(pick(u.text, lang)).split('\n')) {
      final t = p.replaceFirst(RegExp(r'^#+\s*'), '').trim();
      if (t.isNotEmpty) parts.add(SpeechPart(u.uid, t));
    }
    for (final row in u.rowsFor(lang)) {
      final t = row.map(plainLinks).where((c) => c.isNotEmpty).join(', ');
      if (t.isNotEmpty) parts.add(SpeechPart(u.uid, t));
    }
  }
  return parts;
}

class ReadAloud extends ChangeNotifier {
  ReadAloud(this.service);

  final SpeechService service;
  List<SpeechPart> _parts = const [];
  int _index = 0;
  String _artefactId = '';
  bool _playing = false;
  int _run = 0;

  bool get playing => _playing;
  String get artefactId => _artefactId;
  String? get currentUid =>
      _playing && _index < _parts.length ? _parts[_index].uid : null;
  int get index => _index;
  int get length => _parts.length;

  /// Starts reading [a]; returns the availability so the caller can explain a failure.
  Future<SpeechAvailability> start(Artefact a, String lang, double rate) async {
    await stop();
    final availability = await service.prepare(lang);
    if (availability != SpeechAvailability.available) return availability;
    _parts = speechParts(a, lang);
    _artefactId = a.id;
    _index = 0;
    _playing = true;
    notifyListeners();
    _loop(rate);
    return availability;
  }

  Future<void> _loop(double rate) async {
    final run = ++_run;
    while (_playing && run == _run && _index < _parts.length) {
      await service.speak(_parts[_index].text, rate: rate);
      if (!_playing || run != _run) return;
      _index++;
      notifyListeners();
    }
    if (run == _run) {
      _playing = false;
      notifyListeners();
    }
  }

  Future<void> step(int delta, double rate) async {
    if (_parts.isEmpty) return;
    _run++;
    await service.stop();
    _index = (_index + delta).clamp(0, _parts.length - 1);
    _playing = true;
    notifyListeners();
    _loop(rate);
  }

  Future<void> stop() async {
    if (!_playing) return;
    _playing = false;
    _run++;
    notifyListeners();
    await service.stop();
  }
}

class Speech extends InheritedNotifier<ReadAloud> {
  const Speech({super.key, required ReadAloud reader, required super.child})
    : super(notifier: reader);

  static ReadAloud of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Speech>()!.notifier!;
}
