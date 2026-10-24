// Persistent reader settings (APP-LIFE-001: what survives close-and-reopen).
//
// Persistent: book language, last section read. Everything else is transient and
// resets on a cold start; in-session state survives process death through state
// restoration instead (see HomePage).
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends ChangeNotifier {
  Settings(
    this._prefs, {
    required List<String> available,
    String? systemLanguage,
  }) : _language = _initialLanguage(_prefs, available, systemLanguage),
       _available = available;

  static const _kLanguage = 'language';
  static const _kLastSection = 'lastSection';

  final SharedPreferences _prefs;
  final List<String> _available;
  String _language;

  static String _initialLanguage(
    SharedPreferences prefs,
    List<String> available,
    String? system,
  ) {
    final saved = prefs.getString(_kLanguage);
    if (saved != null && available.contains(saved)) return saved;
    if (system != null && available.contains(system)) return system;
    return available.isEmpty ? 'en' : available.first;
  }

  List<String> get available => _available;
  String get language => _language;
  String? get lastSection => _prefs.getString(_kLastSection);

  Future<void> setLanguage(String lang) async {
    if (lang == _language || !_available.contains(lang)) return;
    _language = lang;
    notifyListeners();
    await _prefs.setString(_kLanguage, lang);
  }

  Future<void> setLastSection(String id) async {
    if (id == lastSection) return;
    await _prefs.setString(_kLastSection, id);
    notifyListeners();
  }
}
