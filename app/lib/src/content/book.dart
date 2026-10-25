// The book model, loaded from the bundle the wizard writes (assets/content/content.json).
// APP-CNT-001 (structure), APP-CNT-004 (offline: everything is bundled).
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef Localized = Map<String, String>;

String pick(Localized text, String lang) =>
    text[lang] ?? text['en'] ?? (text.isEmpty ? '' : text.values.first);

final _link = RegExp(r'⟦[^|⟧]+\|([^⟧]*)⟧');

/// Bundle text carries links as `⟦artefact-id|label⟧` (schema 2); plain text keeps the label.
String plainLinks(String text) => text.replaceAllMapped(_link, (m) => m[1]!);

Localized _localized(Object? json) => json is Map
    ? json.map((k, v) => MapEntry(k as String, plainLinks(v as String)))
    : {};

class Unit {
  Unit({
    required this.uid,
    required this.kind,
    required this.text,
    required this.rows,
    required this.images,
    required this.caption,
  });

  factory Unit.fromJson(Map<String, dynamic> j) => Unit(
    uid: j['uid'] as String,
    kind: j['kind'] as String,
    text: _localized(j['text']),
    rows: (j['rows'] as Map<String, dynamic>? ?? {}).map(
      (lang, rows) => MapEntry(lang, [
        for (final row in rows as List)
          [for (final cell in row as List) plainLinks(cell as String)],
      ]),
    ),
    images: [for (final i in j['images'] as List? ?? const []) i as String],
    caption: _localized(j['caption']),
  );

  final String uid;
  final String kind;
  final Localized text;
  final Map<String, List<List<String>>> rows;
  final List<String> images;
  final Localized caption;

  List<List<String>> rowsFor(String lang) =>
      rows[lang] ?? rows['en'] ?? const [];
}

class Section {
  Section({
    required this.id,
    required this.chapter,
    required this.order,
    required this.level,
    required this.title,
    required this.units,
  });

  factory Section.fromJson(Map<String, dynamic> j) => Section(
    id: j['id'] as String,
    chapter: j['chapter'] as String,
    order: j['order'] as int,
    level: j['level'] as int,
    title: _localized(j['title']),
    units: [
      for (final u in j['units'] as List)
        Unit.fromJson(u as Map<String, dynamic>),
    ],
  );

  final String id;
  final String chapter;
  final int order;
  final int level;
  final Localized title;
  final List<Unit> units;

  /// Plain text of the section in [lang], used by search.
  String plainText(String lang) => [
    pick(title, lang),
    for (final u in units) ...[
      pick(u.text, lang),
      pick(u.caption, lang),
      for (final row in u.rowsFor(lang)) row.join(' '),
    ],
  ].join('\n');
}

class Chapter {
  Chapter({required this.id, required this.label, required this.sectionIds});

  factory Chapter.fromJson(Map<String, dynamic> j) => Chapter(
    id: j['id'] as String,
    label: j['label'] as String,
    sectionIds: [for (final s in j['sections'] as List) s as String],
  );

  final String id;
  final String label;
  final List<String> sectionIds;
}

class Entity {
  Entity({
    required this.id,
    required this.group,
    this.subgroup = '',
    required this.title,
    required this.text,
  });

  factory Entity.fromJson(Map<String, dynamic> j) => Entity(
    id: j['id'] as String,
    group: j['group'] as String,
    subgroup: j['subgroup'] as String? ?? '',
    title: _localized(j['title']),
    text: {'en': _entityText(j['units'] as List? ?? const [])},
  );

  static String _entityText(List units) => [
    for (final u in units.cast<Map<String, dynamic>>())
      if (u['kind'] == 'table')
        for (final row in (u['rows'] as Map)['en'] as List)
          (row as List).map((c) => plainLinks(c as String)).join(' · ')
      else
        plainLinks(((u['text'] as Map?)?['en'] as String?) ?? ''),
  ].join('\n');

  final String id;
  final String group;

  /// Kind within a group, e.g. "books" or "auctions" for references (bull DR-014).
  final String subgroup;
  final Localized title;
  final Localized text;
}

class Book {
  Book({
    required this.languages,
    required this.chapters,
    required this.sections,
    required this.entities,
  }) : _index = {for (var i = 0; i < sections.length; i++) sections[i].id: i};

  factory Book.fromJson(Map<String, dynamic> j) => Book(
    languages: [for (final l in j['languages'] as List) l as String],
    chapters: [
      for (final c in j['chapters'] as List)
        Chapter.fromJson(c as Map<String, dynamic>),
    ],
    sections: [
      for (final s in j['sections'] as List)
        Section.fromJson(s as Map<String, dynamic>),
    ],
    entities: [
      for (final e in j['entities'] as List? ?? const [])
        Entity.fromJson(e as Map<String, dynamic>),
    ],
  );

  static const assetPath = 'assets/content/content.json';

  /// Loads the bundled book, or returns null when the bundle has not been built.
  static Future<Book?> load(AssetBundle bundle) async {
    try {
      final raw = await bundle.loadString(assetPath, cache: false);
      return Book.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FlutterError {
      return null;
    }
  }

  final List<String> languages;
  final List<Chapter> chapters;
  final List<Section> sections;
  final List<Entity> entities;
  final Map<String, int> _index;

  Section? section(String id) =>
      _index[id] == null ? null : sections[_index[id]!];

  Section? neighbour(String id, int delta) {
    final i = _index[id];
    if (i == null) return null;
    final j = i + delta;
    return j >= 0 && j < sections.length ? sections[j] : null;
  }

  List<Section> sectionsOf(Chapter chapter) => [
    for (final id in chapter.sectionIds)
      if (section(id) != null) section(id)!,
  ];
}
