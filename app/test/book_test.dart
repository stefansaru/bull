// Content model (APP-CNT-001), links and previews (UIC-LNK), navigation (UIC-PRN-01),
// the Sections window and indexes (UIC-NAV-01a), search (UIC-SRC), favorites (UIC-FAV),
// the more menu (UIC-NAV-02..06) and read aloud (UIC-NAV-03).
import 'package:capdebour/src/content/book.dart';
import 'package:capdebour/src/content/inline.dart';
import 'package:capdebour/src/settings.dart';
import 'package:capdebour/src/speech/speech_service.dart';
import 'package:capdebour/src/ui/search_page.dart';
import 'package:capdebour/src/ui/tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text, findRichText: true);
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

void main() {
  group('model', () {
    test('sections are in book order and navigable', () {
      final book = fixtureBook();
      expect(book.sections.map((s) => s.id), ['s1', 's2', 's3', 'cal-1858']);
      expect(book.neighbour('s1', 1)?.id, 's2');
      expect(book.neighbour('s1', -1), isNull);
      expect(book.sectionsOf(book.chapters.first).length, 2);
    });

    test('every page is an artefact, found by id', () {
      final book = fixtureBook();
      expect(book.artefact('s2'), isA<Section>());
      expect(book.artefact('entities/colors/carmine-red'), isA<Entity>());
      expect(book.artefact('index/colours'), isA<IndexInfo>());
      expect(book.calendarFor('1858')?.id, 'cal-1858');
    });

    test('links parse into spans; plain text keeps the labels', () {
      const text = 'In ⟦entities/colors/carmine-red|carmine red⟧ ink';
      final parts = parseInline(text);
      expect(parts.map((p) => p.text), ['In ', 'carmine red', ' ink']);
      expect(parts[1].target, 'entities/colors/carmine-red');
      expect(plainLinks(text), 'In carmine red ink');
      final s1 = fixtureBook().section('s1')!;
      expect(s1.plainText('en'), contains('Printed in carmine red'));
    });

    test('missing translations fall back to English', () {
      final s2 = fixtureBook().section('s2')!;
      expect(pick(s2.title, 'ro'), '1858 Why this book');
    });

    test('an older bundle schema is refused with a clear message', () {
      expect(
        () => Book.fromJson({
          'schema': 1,
          'languages': ['en'],
          'chapters': [],
          'sections': [],
        }),
        throwsFormatException,
      );
    });
  });

  testWidgets('a prose link previews first; More opens; Back returns', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapLink(tester, 'carmine red');
    expect(
      find.text('Carmine red — matched in the book to Pantone 1807.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('The first stamps of Moldavia.'), findsOneWidget);

    await tapLink(tester, 'carmine red');
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.text('Pantone 1807 — Carmine Red'), findsOneWidget);
    expect(find.text('#A4343A'), findsOneWidget);
    await tapTooltip(tester, 'Back');
    expect(find.text('The first stamps of Moldavia.'), findsOneWidget);
  });

  testWidgets('Related entries open directly, without a preview', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapLink(tester, 'carmine red');
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tapText(tester, '27 parale');
    expect(find.text('More'), findsNothing);
    expect(find.text('The lowest value.'), findsOneWidget);
  });

  testWidgets('wandering never moves Continue reading', (tester) async {
    final (_, settings) = await pumpApp(tester);
    await tapText(tester, 'Next');
    expect(settings.lastSection, 's2');
    await tapLink(tester, 'carmine red'); // in the table
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(settings.lastSection, 's2');
    expect(settings.recents.first, 'entities/colors/carmine-red');
  });

  testWidgets('the date line links its year to that year\'s calendar', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapText(tester, 'Next');
    expect(
      find.text('Why this book'),
      findsOneWidget,
    ); // year left out of the title
    await tapText(tester, '1858');
    expect(find.text('Julian and Gregorian days of 1858.'), findsOneWidget);
  });

  testWidgets('Sections: contents, indexes and favorites have entry points', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapTooltip(tester, 'Contents');
    for (final t in ['Indexes', 'Images', 'Abbreviations', 'Colours']) {
      expect(find.text(t), findsWidgets);
    }
    expect(find.text('Favorites'), findsOneWidget);
    await tapText(tester, 'Colours');
    expect(find.text('Reds'), findsOneWidget);
    await tapText(tester, 'Carmine red');
    expect(find.text('Pantone 1807 — Carmine Red'), findsOneWidget);
  });

  testWidgets('an abbreviation lists its letter and leads to the index', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapTooltip(tester, 'Contents');
    await tapText(tester, 'Abbreviations');
    await tapText(tester, 'Julian calendar');
    expect(find.text('Starting with J'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'JT'), findsOneWidget);
    await tapText(tester, 'All abbreviations');
    expect(find.text('Joint test'), findsOneWidget);
  });

  testWidgets('search finds sections and entities; filters show a count', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapTooltip(tester, 'Search');
    await tester.enterText(find.byType(TextField), 'red');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Carmine red'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Introduction'), findsOneWidget);
    expect(find.text('Filters'), findsOneWidget);

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Colours'));
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('Filters (1)'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Introduction'), findsNothing);
    await tester.tap(find.widgetWithText(ListTile, 'Carmine red'));
    await tester.pumpAndSettle();
    expect(find.text('Pantone 1807 — Carmine Red'), findsOneWidget);
  });

  test('search filters combine type, chapter and favorites', () {
    final book = fixtureBook();
    final all = searchBook(book, 'en', 'aurochs', const SearchFilters(), {});
    expect(all.map((h) => h.artefact.id), containsAll(['s2', 's3']));
    final chapter = searchBook(
      book,
      'en',
      'aurochs',
      const SearchFilters(chapter: '02-aurochs'),
      {},
    );
    expect(chapter.map((h) => h.artefact.id), ['s3']);
    final favs = searchBook(
      book,
      'en',
      '',
      const SearchFilters(favoritesOnly: true),
      {'s3'},
    );
    expect(favs.map((h) => h.artefact.id), ['s3']);
  });

  testWidgets('the star keeps a page; favorites can be deleted', (
    tester,
  ) async {
    final (_, settings) = await pumpApp(tester);
    await tapTooltip(tester, 'Add to favorites');
    expect(settings.isFavorite('s1'), isTrue);
    expect(find.byTooltip('Remove from favorites'), findsOneWidget);
    await settings.addBookmark(
      const Bookmark(
        artefactId: 's2',
        kind: BookmarkKind.passage,
        anchor: 'u3',
        created: 1,
      ),
    );
    await tapTooltip(tester, 'Contents');
    await tapText(tester, 'Favorites');
    expect(find.text('Introduction'), findsWidgets);
    await tester.tap(find.byTooltip('Delete all bookmarks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(settings.bookmarks, isEmpty);
    expect(find.textContaining('Nothing saved yet'), findsOneWidget);
  });

  testWidgets('colours: theme and vision mode are two separate choices', (
    tester,
  ) async {
    final (_, settings) = await pumpApp(tester);
    await tapTooltip(tester, 'More options');
    await tapText(tester, 'Colours');
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tritan Safe'));
    await tester.pumpAndSettle();
    expect(settings.theme, ThemeChoice.dark);
    expect(settings.vision, VisionMode.tritanSafe);
  });

  testWidgets('language window shows language and country', (tester) async {
    await pumpApp(tester);
    await tapTooltip(tester, 'More options');
    await tapText(tester, 'Book language');
    expect(find.textContaining('EN · English'), findsOneWidget);
    expect(find.textContaining('RO · Română'), findsOneWidget);
  });

  testWidgets('read aloud speaks the page in order', (tester) async {
    final speech = FakeSpeech(delay: const Duration(seconds: 1));
    await pumpApp(tester, speech: speech);
    await tapTooltip(tester, 'More options');
    await tester.tap(find.text('Read this page aloud'));
    await tester.pump(); // the sheet starts closing
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byTooltip('Stop reading'), findsOneWidget);
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.byTooltip('Stop reading'), findsNothing); // finished
    expect(speech.spoken.take(3), [
      'Introduction',
      'The first stamps of Moldavia.',
      'Printed in carmine red on 1 (13) June 1858 ᴶ⁄ᴳ.',
    ]);
  });

  testWidgets('read aloud explains a missing voice, never substitutes', (
    tester,
  ) async {
    final speech = FakeSpeech(availability: SpeechAvailability.noVoice);
    await pumpApp(tester, speech: speech);
    await tapTooltip(tester, 'More options');
    await tapText(tester, 'Read this page aloud');
    expect(
      find.textContaining('Read aloud is unavailable for English'),
      findsOneWidget,
    );
    expect(speech.spoken, isEmpty);
  });

  testWidgets('Skip defers the first-run tour; Skip all ends it', (
    tester,
  ) async {
    final (_, settings) = await pumpApp(tester, prefs: const {});
    expect(find.textContaining('short tour'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.textContaining('short tour'), findsNothing);
    expect(settings.tourSeen, isFalse); // shows again next launch

    await tapTooltip(tester, 'More options');
    await tapText(tester, 'Help');
    await tapText(tester, 'Tour of the controls');
    await tester.tap(find.text('Skip all'));
    await tester.pumpAndSettle();
    expect(settings.tourSeen, isTrue);
  });

  Rect? spotlight(WidgetTester tester) {
    final paint = tester.widget<CustomPaint>(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is TourSpotlightPainter,
      ),
    );
    return (paint.painter! as TourSpotlightPainter).hole;
  }

  Future<void> tourButton(WidgetTester tester, String label) async {
    await tester.tap(
      find
          .ancestor(
            of: find.text(label),
            matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
          )
          .last,
    );
    await tester.pumpAndSettle();
  }

  /// The frame surrounds the control and all four sides are on screen.
  void framesControl(WidgetTester tester, String tooltip) {
    final hole = spotlight(tester)!;
    final control = tester.getRect(
      find
          .ancestor(
            of: find.byTooltip(tooltip).first,
            matching: find.byType(IconButton),
          )
          .first,
    );
    final screen = Offset.zero & tester.view.physicalSize;
    expect(hole.contains(control.center), isTrue, reason: tooltip);
    expect(hole.overlaps(control), isTrue, reason: tooltip);
    expect(
      screen.deflate(tourFrameWidth / 2).contains(hole.topLeft) &&
          screen.deflate(tourFrameWidth / 2).contains(hole.bottomRight),
      isTrue,
      reason: '$tooltip frame $hole leaves the screen $screen',
    );
    expect(
      hole.width,
      greaterThanOrEqualTo(control.width - 2),
      reason: tooltip,
    );
  }

  testWidgets('the tour spotlight follows the controls through a rotation', (
    tester,
  ) async {
    // Started in landscape (rail), turned to portrait (top menu) mid-tour: the
    // spotlight must sit on the control as it is now, not where it was.
    await pumpApp(tester, size: phoneLandscape, prefs: const {});
    await tourButton(tester, 'Next');
    framesControl(tester, 'Back');
    expect(find.text('2 / 8'), findsOneWidget); // landscape has the title step

    await setSize(tester, phonePortrait);
    await tester.pumpAndSettle();
    framesControl(tester, 'Back');
    expect(find.text('2 / 7'), findsOneWidget); // portrait has no title button

    for (final tooltip in ['Contents', 'Add to favorites', 'Search']) {
      await tourButton(tester, 'Next');
      framesControl(tester, tooltip);
    }
    await tourButton(tester, 'Next');
    framesControl(tester, 'More options');

    await tourButton(tester, 'Previous');
    framesControl(tester, 'Search');
    expect(find.text('5 / 7'), findsOneWidget);
  });

  testWidgets('the tour spotlight glides between controls', (tester) async {
    await pumpApp(tester, prefs: const {});
    await tourButton(tester, 'Next');
    final back = spotlight(tester)!;
    await tester.tap(
      find
          .ancestor(
            of: find.text('Next'),
            matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
          )
          .last,
    );
    await tester.pump();
    await tester.pump(tourMorphDuration ~/ 2);
    final midway = spotlight(tester)!;
    await tester.pumpAndSettle();
    final contents = spotlight(tester)!;
    expect(midway, isNot(back));
    expect(midway, isNot(contents));
    expect(
      midway.center.dx,
      inExclusiveRange(back.center.dx, contents.center.dx),
    );
  });
}
