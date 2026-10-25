// The book model, loaded from the bundle the wizard writes (assets/content/content.json,
// schema 2). APP-CNT-001 (structure), APP-CNT-004 (offline: everything is bundled).
//
// Every page is an *artefact* (UIC-ART-01): a narrative section, an entity, an index,
// or an image. Text keeps its links as `⟦artefact-id|label⟧` (see inline.dart).
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'inline.dart';

typedef Localized = Map<String, String>;

const bundleSchema = 2;

String pick(Localized text, String lang) =>
    text[lang] ?? text['en'] ?? (text.isEmpty ? '' : text.values.first);

Localized _localized(Object? json) => json is Map
    ? json.map((k, v) => MapEntry(k as String, '$v'))
    : <String, String>{};

String _str(Object? v) => v == null ? '' : '$v';

class Unit {
  Unit({
    required this.uid,
    required this.kind,
    this.text = const {},
    this.rows = const {},
    this.head = 0,
    this.images = const [],
    this.caption = const {},
  });

  factory Unit.fromJson(Map<String, dynamic> j) => Unit(
    uid: j['uid'] as String,
    kind: j['kind'] as String,
    text: _localized(j['text']),
    rows: (j['rows'] as Map<String, dynamic>? ?? {}).map(
      (lang, rows) => MapEntry(lang, [
        for (final row in rows as List)
          [for (final cell in row as List) cell as String],
      ]),
    ),
    head: j['head'] as int? ?? 0,
    images: [for (final i in j['images'] as List? ?? const []) i as String],
    caption: _localized(j['caption']),
  );

  final String uid;

  /// text, quad, figure, table (narrative); heading, text, list, table (entities).
  final String kind;
  final Localized text;
  final Map<String, List<List<String>>> rows;

  /// Number of header rows of a table.
  final int head;
  final List<String> images;
  final Localized caption;

  List<List<String>> rowsFor(String lang) =>
      rows[lang] ?? rows['en'] ?? const [];

  String plain(String lang) => [
    plainLinks(pick(text, lang)),
    plainLinks(pick(caption, lang)),
    for (final row in rowsFor(lang)) row.map(plainLinks).join(' '),
  ].where((s) => s.isNotEmpty).join('\n');
}

class Relation {
  const Relation(this.id, this.rel);
  final String id;

  /// related, see, issue, denomination, handstamp, series, published in,
  /// in the book, reference.
  final String rel;
}

class Swatch {
  Swatch.fromJson(Map<String, dynamic> j)
    : system = _str(j['system']),
      code = _str(j['code']),
      name = _str(j['name']),
      description = _str(j['description']),
      hex = _str(j['hex']);

  final String system, code, name, description, hex;

  static const _systems = {
    'pantone': 'Pantone',
    'ral': 'RAL',
    'ams': 'AMS',
    'ams-std': 'AMS-STD',
    'ncs': 'NCS',
    'web': 'Web',
  };

  String get label =>
      [_systems[system] ?? '', code].where((s) => s.isNotEmpty).join(' ');
}

enum ArtefactKind { section, entity, indexPage, image }

/// The shared face of every page (UIC-ART).
abstract class Artefact {
  String get id;
  ArtefactKind get kind;
  Localized get title;
  Localized get summary;

  /// A year or a range ("1858", "1858–1862"); empty when the artefact has no time.
  String get year;
  List<Unit> get units;
  List<Relation> get related;
}

class Section implements Artefact {
  Section({
    required this.id,
    required this.chapter,
    required this.order,
    required this.level,
    required this.title,
    this.summary = const {},
    this.year = '',
    required this.units,
  });

  factory Section.fromJson(Map<String, dynamic> j) => Section(
    id: j['id'] as String,
    chapter: j['chapter'] as String,
    order: j['order'] as int,
    level: j['level'] as int,
    title: _localized(j['title']),
    summary: _localized(j['summary']),
    year: _str(j['year']),
    units: [
      for (final u in j['units'] as List)
        Unit.fromJson(u as Map<String, dynamic>),
    ],
  );

  @override
  final String id;
  final String chapter;
  final int order;
  final int level;
  @override
  final Localized title;
  @override
  final Localized summary;
  @override
  final String year;
  @override
  final List<Unit> units;
  @override
  ArtefactKind get kind => ArtefactKind.section;
  @override
  List<Relation> get related => const [];

  /// Plain text of the section in [lang], used by search.
  String plainText(String lang) => [
    pick(title, lang),
    for (final u in units) u.plain(lang),
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

class Entity implements Artefact {
  Entity({
    required this.id,
    required this.type,
    required this.group,
    this.subgroup = '',
    required this.title,
    this.summary = const {},
    this.year = '',
    this.units = const [],
    this.related = const [],
    this.marker = '',
    this.hex = '',
    this.family = '',
    this.swatches = const [],
    this.abbr = '',
    this.forms = const [],
    this.category = '',
    this.expansion = const {},
  });

  factory Entity.fromJson(Map<String, dynamic> j) => Entity(
    id: j['id'] as String,
    type: _str(j['type']),
    group: j['group'] as String,
    subgroup: j['subgroup'] as String? ?? '',
    title: _localized(j['title']),
    summary: _localized(j['summary']),
    year: _str(j['year']),
    units: [
      for (final u in j['units'] as List? ?? const [])
        Unit.fromJson(u as Map<String, dynamic>),
    ],
    related: [
      for (final r in j['related'] as List? ?? const [])
        Relation((r as Map)['id'] as String, _str(r['rel'])),
    ],
    marker: _str(j['marker']),
    hex: _str(j['hex']),
    family: _str(j['family']),
    swatches: [
      for (final s in j['swatches'] as List? ?? const [])
        Swatch.fromJson((s as Map).cast<String, dynamic>()),
    ],
    abbr: _str(j['abbr']),
    forms: [for (final f in j['forms'] as List? ?? const []) '$f'],
    category: _str(j['category']),
    expansion: _localized(j['expansion']),
  );

  @override
  final String id;
  final String type;
  final String group;

  /// Kind within a group, e.g. "books" or "auctions" for references (bull DR-014).
  final String subgroup;
  @override
  final Localized title;
  @override
  final Localized summary;
  @override
  final String year;
  @override
  final List<Unit> units;
  @override
  final List<Relation> related;
  final String marker;

  /// Colour pages: the page swatch, family and the standards the book names.
  final String hex;
  final String family;
  final List<Swatch> swatches;

  /// Abbreviation pages (Table 2).
  final String abbr;
  final List<String> forms;
  final String category;
  final Localized expansion;

  @override
  ArtefactKind get kind => ArtefactKind.entity;

  String plainText(String lang) => [
    pick(title, lang),
    pick(summary, lang),
    for (final u in units) u.plain(lang),
  ].join('\n');
}

class BookImage implements Artefact {
  BookImage.fromJson(Map<String, dynamic> j)
    : id = 'image/${j['id']}',
      imageId = j['id'] as String,
      number = j['number'] as int,
      file = j['file'] as String,
      caption = _localized(j['caption']),
      unit = _str(j['unit']),
      section = _str(j['section']);

  @override
  final String id;

  /// Stable across content changes: bookmarks store this, never [number].
  final String imageId;

  /// Display order among the images that ship.
  final int number;
  final String file;
  final Localized caption;
  final String unit;
  final String section;

  String get asset => 'assets/content/$file';

  @override
  ArtefactKind get kind => ArtefactKind.image;
  @override
  Localized get title => caption;
  @override
  Localized get summary => caption;
  @override
  String get year => '';
  @override
  List<Unit> get units => const [];
  @override
  List<Relation> get related => [Relation(section, 'in the book')];
}

class IndexInfo implements Artefact {
  IndexInfo.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      title = _localized(j['title']),
      items = [for (final i in j['items'] as List? ?? const []) i as String];

  @override
  final String id;
  @override
  final Localized title;
  final List<String> items;

  @override
  ArtefactKind get kind => ArtefactKind.indexPage;
  @override
  Localized get summary => const {};
  @override
  String get year => '';
  @override
  List<Unit> get units => const [];
  @override
  List<Relation> get related => const [];
}

class Book {
  Book({
    required this.languages,
    required this.chapters,
    required this.sections,
    required this.entities,
    this.images = const [],
    this.indexes = const [],
  }) : _index = {for (var i = 0; i < sections.length; i++) sections[i].id: i},
       _artefacts = {
         for (final s in sections) s.id: s,
         for (final e in entities) e.id: e,
         for (final i in images) i.id: i,
         for (final i in indexes) i.id: i,
       };

  factory Book.fromJson(Map<String, dynamic> j) {
    final schema = j['schema'] as int? ?? bundleSchema;
    if (schema != bundleSchema) {
      throw FormatException(
        'content.json schema $schema; this app reads schema $bundleSchema. '
        'Rebuild the bundle with the wizard.',
      );
    }
    return Book(
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
      images: [
        for (final i in j['images'] as List? ?? const [])
          BookImage.fromJson(i as Map<String, dynamic>),
      ],
      indexes: [
        for (final i in j['indexes'] as List? ?? const [])
          IndexInfo.fromJson(i as Map<String, dynamic>),
      ],
    );
  }

  static const assetPath = 'assets/content/content.json';

  /// Loads the bundled book, or returns null when the bundle has not been built
  /// or was built for another schema.
  static Future<Book?> load(AssetBundle bundle) async {
    try {
      final raw = await bundle.loadString(assetPath, cache: false);
      return Book.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FlutterError {
      return null;
    } on FormatException catch (e) {
      debugPrint('$e');
      return null;
    }
  }

  final List<String> languages;
  final List<Chapter> chapters;
  final List<Section> sections;
  final List<Entity> entities;
  final List<BookImage> images;
  final List<IndexInfo> indexes;
  final Map<String, int> _index;
  final Map<String, Artefact> _artefacts;

  Artefact? artefact(String id) => _artefacts[id];

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

  Chapter? chapterOf(Section s) =>
      chapters.where((c) => c.id == s.chapter).firstOrNull;

  List<Entity> entitiesOfType(String type) => [
    for (final e in entities)
      if (e.type == type) e,
  ];

  BookImage? imageByFile(String file) =>
      images.where((i) => i.file == file).firstOrNull;

  /// The calendar concordance section for [year] (chapter 21), if the book has one.
  Section? calendarFor(String year) => sections
      .where((s) => s.chapter.endsWith('-calendar') && s.year == year)
      .firstOrNull;
}
