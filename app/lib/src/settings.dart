// Persistent reader state (APP-LIFE-001: what survives close-and-reopen).
//
// Persistent: book language and its display order, theme and vision mode, sound and
// read-aloud preferences, the reading position ("Continue reading"), recently visited
// artefacts, favorites and bookmarks, and whether the first-run tour was seen.
// In-session navigation survives process death through state restoration instead
// (see nav/nav_stack.dart).
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Light/dark (UIC-NAV-06, theme axis).
enum ThemeChoice { automatic, light, dark }

/// Colour-vision mode (UIC-NAV-06, vision axis). Recolours the interface only:
/// stamp images and colour swatches always keep their own colours.
enum VisionMode { standard, redGreenSafe, tritanSafe, grayscale }

/// What a bookmark points at (UIC-FAV-03). The star marks a whole artefact.
enum BookmarkKind { artefact, passage, table, image }

class Bookmark {
  const Bookmark({
    required this.artefactId,
    required this.kind,
    this.anchor = '',
    this.rows = const [],
    this.cols = const [],
    this.label = '',
    required this.created,
  });

  factory Bookmark.fromJson(Map<String, dynamic> j) => Bookmark(
    artefactId: j['a'] as String,
    kind: BookmarkKind.values.byName(j['k'] as String),
    anchor: j['u'] as String? ?? '',
    rows: [for (final r in j['r'] as List? ?? const []) '$r'],
    cols: [for (final c in j['c'] as List? ?? const []) '$c'],
    label: j['l'] as String? ?? '',
    created: j['t'] as int? ?? 0,
  );

  final String artefactId;
  final BookmarkKind kind;

  /// Stable anchor: a unit uid (passage, table) or an image id.
  final String anchor;

  /// Table selections: stable row and column ids (`<uid>-r<n>`, `<uid>-c<n>`).
  final List<String> rows;
  final List<String> cols;
  final String label;
  final int created;

  String get key =>
      '$artefactId|${kind.name}|$anchor|${rows.join(',')}|${cols.join(',')}';

  Map<String, dynamic> toJson() => {
    'a': artefactId,
    'k': kind.name,
    if (anchor.isNotEmpty) 'u': anchor,
    if (rows.isNotEmpty) 'r': rows,
    if (cols.isNotEmpty) 'c': cols,
    if (label.isNotEmpty) 'l': label,
    't': created,
  };
}

class Settings extends ChangeNotifier {
  Settings(
    this._prefs, {
    required List<String> available,
    String? systemLanguage,
  }) : _language = _initialLanguage(_prefs, available, systemLanguage),
       _available = available;

  static const _kLanguage = 'language';
  static const _kLanguageOrder = 'languageOrder';
  static const _kLastSection = 'lastSection';
  static const _kTheme = 'theme';
  static const _kVision = 'vision';
  static const _kSfx = 'sfx';
  static const _kTtsRate = 'ttsRate';
  static const _kRecents = 'recents';
  static const _kBookmarks = 'bookmarks';
  static const _kTourSeen = 'tourSeen';
  static const recentsCap = 30;

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

  /// Languages in the reader's chosen display order (UIC-NAV-04).
  List<String> get languageOrder {
    final saved = _prefs.getStringList(_kLanguageOrder) ?? const [];
    return [
      for (final l in saved)
        if (_available.contains(l)) l,
      for (final l in _available)
        if (!saved.contains(l)) l,
    ];
  }

  ThemeChoice get theme =>
      ThemeChoice.values.asNameMap()[_prefs.getString(_kTheme)] ??
      ThemeChoice.automatic;
  VisionMode get vision =>
      VisionMode.values.asNameMap()[_prefs.getString(_kVision)] ??
      VisionMode.standard;
  bool get soundEffects => _prefs.getBool(_kSfx) ?? true;
  double get speechRate => _prefs.getDouble(_kTtsRate) ?? 0.5;
  bool get tourSeen => _prefs.getBool(_kTourSeen) ?? false;
  List<String> get recents => _prefs.getStringList(_kRecents) ?? const [];

  List<Bookmark> get bookmarks {
    final raw = _prefs.getString(_kBookmarks);
    if (raw == null) return const [];
    return [
      for (final b in jsonDecode(raw) as List)
        Bookmark.fromJson((b as Map).cast<String, dynamic>()),
    ];
  }

  bool isFavorite(String artefactId) => bookmarks.any(
    (b) => b.artefactId == artefactId && b.kind == BookmarkKind.artefact,
  );

  Set<String> get favoriteIds => {for (final b in bookmarks) b.artefactId};

  Future<void> setLanguage(String lang) async {
    if (lang == _language || !_available.contains(lang)) return;
    _language = lang;
    notifyListeners();
    await _prefs.setString(_kLanguage, lang);
  }

  Future<void> setLanguageOrder(List<String> order) async {
    await _prefs.setStringList(_kLanguageOrder, order);
    notifyListeners();
  }

  Future<void> setTheme(ThemeChoice t) async {
    await _prefs.setString(_kTheme, t.name);
    notifyListeners();
  }

  Future<void> setVision(VisionMode v) async {
    await _prefs.setString(_kVision, v.name);
    notifyListeners();
  }

  Future<void> setSoundEffects(bool on) async {
    await _prefs.setBool(_kSfx, on);
    notifyListeners();
  }

  Future<void> setSpeechRate(double rate) async {
    await _prefs.setDouble(_kTtsRate, rate);
    notifyListeners();
  }

  Future<void> setTourSeen() async {
    await _prefs.setBool(_kTourSeen, true);
    notifyListeners();
  }

  /// Linear reading only (UIC-FAV-04): wandering through links never moves it.
  Future<void> setLastSection(String id) async {
    if (id == lastSection) return;
    await _prefs.setString(_kLastSection, id);
    notifyListeners();
  }

  Future<void> addRecent(String artefactId) async {
    if (recents.firstOrNull == artefactId) return;
    final list = [
      artefactId,
      for (final r in recents)
        if (r != artefactId) r,
    ];
    await _prefs.setStringList(
      _kRecents,
      list.take(recentsCap).toList(growable: false),
    );
    notifyListeners();
  }

  Future<void> _saveBookmarks(List<Bookmark> list) async {
    await _prefs.setString(
      _kBookmarks,
      jsonEncode([for (final b in list) b.toJson()]),
    );
    notifyListeners();
  }

  Future<void> addBookmark(Bookmark b) async {
    final list = bookmarks;
    if (list.any((x) => x.key == b.key)) return;
    await _saveBookmarks([...list, b]);
  }

  Future<void> removeBookmark(Bookmark b) => _saveBookmarks([
    for (final x in bookmarks)
      if (x.key != b.key) x,
  ]);

  Future<void> removeBookmarksOf(String artefactId) => _saveBookmarks([
    for (final x in bookmarks)
      if (x.artefactId != artefactId) x,
  ]);

  Future<void> removeAllBookmarks() => _saveBookmarks(const []);

  Future<void> toggleFavorite(String artefactId) async {
    final star = Bookmark(
      artefactId: artefactId,
      kind: BookmarkKind.artefact,
      created: DateTime.now().millisecondsSinceEpoch,
    );
    if (isFavorite(artefactId)) {
      await removeBookmark(star);
    } else {
      await addBookmark(star);
    }
  }
}
