// Content model (APP-CNT-001) and search (APP-SRCH-001).
import 'package:capdebour/src/content/book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('sections are in book order and navigable', () {
    final book = fixtureBook();
    expect(book.sections.map((s) => s.id), ['s1', 's2', 's3']);
    expect(book.neighbour('s1', 1)?.id, 's2');
    expect(book.neighbour('s1', -1), isNull);
    expect(book.neighbour('s3', 1), isNull);
    expect(book.sectionsOf(book.chapters.first).length, 2);
  });

  test('missing translations fall back to English', () {
    final s2 = fixtureBook().section('s2')!;
    expect(pick(s2.title, 'ro'), 'Why this book');
    expect(s2.units[1].rowsFor('ro').first, ['27 parale', 'black']);
  });

  test('plain text covers titles, text and table cells', () {
    final text = fixtureBook().section('s2')!.plainText('en');
    expect(text, contains('Why this book'));
    expect(text, contains('54 parale blue'));
  });

  testWidgets('search finds a section and opens it', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'aurochs');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Why this book'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Why this book'));
    await tester.pumpAndSettle();
    expect(find.text('Because the aurochs head deserves it.'), findsOneWidget);
  });

  testWidgets('reference pages open', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Reference'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Denominations'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('27 parale'));
    await tester.pumpAndSettle();
    expect(find.text('The lowest value.'), findsOneWidget);
  });
}
