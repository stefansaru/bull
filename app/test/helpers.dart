import 'package:capdebour/src/app.dart';
import 'package:capdebour/src/content/book.dart';
import 'package:capdebour/src/platform.dart';
import 'package:capdebour/src/settings.dart';
import 'package:capdebour/src/speech/speech_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Logical sizes for the declared form factors (STRAT-OBJ-001).
const phonePortrait = Size(390, 844);
const phoneLandscape = Size(844, 390);
const tabletPortrait = Size(800, 1280);
const tabletLandscape = Size(1280, 800);
const tv = Size(960, 540);

Map<String, dynamic> _text(String uid, String en, [String? ro]) => {
  'uid': uid,
  'kind': 'text',
  'text': {'en': en, 'ro': ?ro},
};

Book fixtureBook() => Book.fromJson({
  'schema': 2,
  'languages': ['en', 'ro'],
  'chapters': [
    {
      'id': '01-intro',
      'label': 'Introduction',
      'sections': ['s1', 's2'],
    },
    {
      'id': '02-aurochs',
      'label': 'The Aurochs',
      'sections': ['s3'],
    },
    {
      'id': '21-calendar',
      'label': 'Calendar',
      'sections': ['cal-1858'],
    },
  ],
  'sections': [
    {
      'id': 's1',
      'chapter': '01-intro',
      'order': 1,
      'level': 1,
      'title': {'en': 'Introduction', 'ro': 'Introducere'},
      'summary': {'en': 'The first stamps of Moldavia.'},
      'units': [
        _text(
          'u1',
          'The first stamps of Moldavia.',
          'Primele mărci ale Moldovei.',
        ),
        _text(
          'u2',
          'Printed in ⟦entities/colors/carmine-red|carmine red⟧ on '
              '1 (13) June 1858 ⟦entities/concepts/dual-date-notation|ᴶ⁄ᴳ⟧.',
        ),
      ],
    },
    {
      'id': 's2',
      'chapter': '01-intro',
      'order': 2,
      'level': 2,
      'year': '1858',
      'title': {'en': '1858 Why this book'},
      'units': [
        _text('u3', 'Because the aurochs head deserves it.'),
        {
          'uid': 'u4',
          'kind': 'table',
          'text': {},
          'head': 1,
          'rows': {
            'en': [
              ['Value', 'Colour'],
              ['27 parale', '⟦entities/colors/carmine-red|carmine red⟧'],
              ['54 parale', 'blue'],
            ],
          },
        },
      ],
    },
    {
      'id': 's3',
      'chapter': '02-aurochs',
      'order': 3,
      'level': 1,
      'title': {'en': 'The Aurochs'},
      'units': [_text('u5', 'An extinct wild ox, symbol of Moldavia.')],
    },
    {
      'id': 'cal-1858',
      'chapter': '21-calendar',
      'order': 4,
      'level': 2,
      'year': '1858',
      'title': {'en': 'Calendar 1858'},
      'units': [_text('u6', 'Julian and Gregorian days of 1858.')],
    },
  ],
  'entities': [
    {
      'id': 'entities/denominations/27-parale',
      'group': 'denominations',
      'type': 'denomination',
      'title': {'en': '27 parale'},
      'units': [
        {
          'uid': 'd#1',
          'kind': 'heading',
          'text': {'en': '## Design'},
        },
        _text('d#2', 'The lowest value.'),
      ],
      'related': [
        {'id': 'entities/colors/carmine-red', 'rel': 'related'},
      ],
    },
    {
      'id': 'entities/colors/carmine-red',
      'group': 'colors',
      'type': 'color',
      'title': {'en': 'Carmine red', 'ro': 'Roşu carmin'},
      'summary': {'en': 'Carmine red — matched in the book to Pantone 1807.'},
      'hex': '#A4343A',
      'family': 'red',
      'swatches': [
        {
          'system': 'pantone',
          'code': '1807',
          'name': 'Carmine Red',
          'description': '',
          'hex': '#A4343A',
        },
      ],
      'units': [_text('c#1', 'The red of the 27 parale.')],
      'related': [
        {'id': 'entities/denominations/27-parale', 'rel': 'related'},
      ],
    },
    {
      'id': 'entities/abbreviations/abbr-j',
      'group': 'abbreviations',
      'type': 'abbreviation',
      'title': {'en': 'J — Julian calendar'},
      'summary': {'en': 'J: Julian calendar.'},
      'abbr': 'J',
      'forms': ['J'],
      'category': 'calendar',
      'expansion': {'en': 'Julian calendar', 'ro': 'Calendar iulian'},
      'related': [
        {'id': 'entities/concepts/dual-date-notation', 'rel': 'see'},
      ],
    },
    {
      'id': 'entities/abbreviations/abbr-jt',
      'group': 'abbreviations',
      'type': 'abbreviation',
      'title': {'en': 'JT — Joint test'},
      'abbr': 'JT',
      'forms': ['JT'],
      'category': 'general',
      'expansion': {'en': 'Joint test'},
    },
    {
      'id': 'entities/concepts/dual-date-notation',
      'group': 'concepts',
      'type': 'concept',
      'title': {'en': 'Dual dates'},
      'summary': {
        'en': 'The first date is Julian, the date in parentheses Gregorian.',
      },
    },
    {
      'id': 'entities/references/books/dragomir-1990',
      'group': 'references',
      'subgroup': 'books',
      'type': 'reference',
      'title': {'en': 'Dragomir, Ștampilografie poștală (1990)'},
      'units': [_text('r#1', 'The standard reference for handstamps.')],
    },
  ],
  'images': [
    {
      'id': 'media__a',
      'number': 1,
      'file': 'img/media__a.webp',
      'caption': {'en': 'Figure 1: A 27 parale stamp'},
      'unit': 'u1',
      'section': 's1',
    },
    {
      'id': 'media__b',
      'number': 2,
      'file': 'img/media__b.webp',
      'caption': {'en': 'Figure 2: A cover'},
      'unit': 'u3',
      'section': 's2',
    },
  ],
  'indexes': [
    {
      'id': 'index/images',
      'title': {'en': 'Images'},
    },
    {
      'id': 'index/abbreviations',
      'title': {'en': 'Abbreviations'},
    },
    {
      'id': 'index/colours',
      'title': {'en': 'Colours'},
    },
    {
      'id': 'index/calendars',
      'title': {'en': 'Calendars'},
      'items': ['entities/concepts/dual-date-notation', 'cal-1858'],
    },
  ],
});

Future<Settings> settingsFor(
  Book book, [
  Map<String, Object> prefs = const {'tourSeen': true},
]) async {
  SharedPreferences.setMockInitialValues(prefs);
  return Settings(
    await SharedPreferences.getInstance(),
    available: book.languages,
  );
}

Future<void> setSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pump();
}

/// A speech engine for tests: records what it was asked to say.
class FakeSpeech implements SpeechService {
  FakeSpeech({
    this.availability = SpeechAvailability.available,
    this.delay = const Duration(milliseconds: 10),
  });

  final SpeechAvailability availability;
  final Duration delay;
  final spoken = <String>[];

  @override
  Future<SpeechAvailability> prepare(String lang) async => availability;

  @override
  Future<void> speak(String text, {required double rate}) async {
    spoken.add(text);
    await Future<void>.delayed(delay);
  }

  @override
  Future<void> stop() async {}
}

Future<(Book, Settings)> pumpApp(
  WidgetTester tester, {
  Size size = phonePortrait,
  Map<String, Object> prefs = const {'tourSeen': true},
  SpeechService? speech,
  DeviceKind device = DeviceKind.phone,
}) async {
  await setSize(tester, size);
  final book = fixtureBook();
  final settings = await settingsFor(book, prefs);
  await tester.pumpWidget(
    BullApp(
      book: book,
      settings: settings,
      speech: speech ?? FakeSpeech(),
      device: device,
    ),
  );
  await tester.pumpAndSettle();
  return (book, settings);
}

Future<void> tapTooltip(WidgetTester tester, String tooltip) async {
  await tester.tap(find.byTooltip(tooltip).first);
  await tester.pumpAndSettle();
}

/// Taps an inline link (a span inside a paragraph).
Future<void> tapLink(WidgetTester tester, String label) async {
  final range = find.textRange.ofSubstring(label);
  await tester.ensureVisible(
    find.textContaining(label, findRichText: true).first,
  );
  await tester.tapOnText(range.first);
  await tester.pumpAndSettle();
}
