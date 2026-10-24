import 'package:capdebour/src/app.dart';
import 'package:capdebour/src/content/book.dart';
import 'package:capdebour/src/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Logical sizes for the declared form factors (STRAT-OBJ-001).
const phonePortrait = Size(390, 844);
const phoneLandscape = Size(844, 390);
const tabletPortrait = Size(800, 1280);
const tabletLandscape = Size(1280, 800);
const tv = Size(960, 540);

Book fixtureBook() => Book.fromJson({
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
  ],
  'sections': [
    {
      'id': 's1',
      'chapter': '01-intro',
      'order': 1,
      'level': 1,
      'title': {'en': 'Introduction', 'ro': 'Introducere'},
      'units': [
        {
          'uid': 'u1',
          'kind': 'text',
          'text': {
            'en': 'The first stamps of Moldavia.',
            'ro': 'Primele mărci ale Moldovei.',
          },
        },
      ],
    },
    {
      'id': 's2',
      'chapter': '01-intro',
      'order': 2,
      'level': 2,
      'title': {'en': 'Why this book'},
      'units': [
        {
          'uid': 'u2',
          'kind': 'text',
          'text': {'en': 'Because the aurochs head deserves it.'},
        },
        {
          'uid': 'u3',
          'kind': 'table',
          'text': {},
          'rows': {
            'en': [
              ['27 parale', 'black'],
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
      'units': [
        {
          'uid': 'u4',
          'kind': 'text',
          'text': {'en': 'An extinct wild ox, symbol of Moldavia.'},
        },
      ],
    },
  ],
  'entities': [
    {
      'id': 'entities/denominations/27-parale',
      'group': 'denominations',
      'type': 'denomination',
      'title': {'en': '27 parale'},
      'text': {'en': '## Design\nThe lowest value.'},
    },
  ],
});

Future<Settings> settingsFor(
  Book book, [
  Map<String, Object> prefs = const {},
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

Future<(Book, Settings)> pumpApp(
  WidgetTester tester, {
  Size size = phonePortrait,
  Map<String, Object> prefs = const {},
}) async {
  await setSize(tester, size);
  final book = fixtureBook();
  final settings = await settingsFor(book, prefs);
  await tester.pumpWidget(BullApp(book: book, settings: settings));
  await tester.pumpAndSettle();
  return (book, settings);
}

Future<void> openFirstSection(WidgetTester tester) async {
  await tester.tap(find.text('Introduction').first);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ListTile, 'Introduction').last);
  await tester.pumpAndSettle();
}
