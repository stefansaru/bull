// The table viewer (UIC-TBL), passage bookmarks (UIC-FAV-03), the image viewer
// (UIC-IMG), and TV input (UIC-PLT): device kinds, the in-app keyboard, 10-foot type.
import 'package:capdebour/src/platform.dart';
import 'package:capdebour/src/settings.dart';
import 'package:capdebour/src/ui/shell.dart';
import 'package:capdebour/src/ui/table_viewer.dart';
import 'package:capdebour/src/ui/tv_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

Future<void> openSecondSection(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Next'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
}

void main() {
  group('table selection ids', () {
    test('a range encodes to stable row and column ids and back', () {
      const s = TableSelection(1, 2, 0, 1);
      final (rows, cols) = s.ids('u4');
      expect(rows, ['u4-r1', 'u4-r2']);
      expect(cols, ['u4-c0', 'u4-c1']);
      final back = TableSelection.fromIds('u4', rows, cols)!;
      expect((back.r0, back.r1, back.c0, back.c1), (1, 2, 0, 1));
    });

    test('a whole column stores no row ids (all rows)', () {
      const s = TableSelection(0, 0, 1, 1, allRows: true);
      final (rows, cols) = s.ids('u4');
      expect(rows, isEmpty);
      final anchor = TableSelection.anchor('u4', rows, cols);
      final (uid, parsed) = TableSelection.parseAnchor(anchor);
      expect(uid, 'u4');
      expect(parsed!.allRows, isTrue);
      expect(parsed.contains(2, 1), isTrue);
      expect(parsed.contains(2, 0), isFalse);
    });
  });

  testWidgets('table: the remote selects a range; it can be bookmarked', (
    tester,
  ) async {
    final (_, settings) = await pumpApp(tester, size: tv);
    await openSecondSection(tester);
    // Focus the table, then: Select (anchor) → Down → Right → Select (confirm).
    final table = find.byType(TableViewer);
    await tester.ensureVisible(table);
    final node = tester
        .widget<Focus>(
          find.byWidgetPredicate(
            (w) => w is Focus && w.focusNode?.debugLabel == 'table',
          ),
        )
        .focusNode!;
    node.requestFocus();
    await tester.pumpAndSettle();
    await press(
      tester,
      LogicalKeyboardKey.arrowRight,
    ); // (1,1): first body cell
    await press(tester, LogicalKeyboardKey.select);
    await press(tester, LogicalKeyboardKey.arrowDown);
    await press(tester, LogicalKeyboardKey.select);
    expect(find.text('Bookmark selection'), findsOneWidget);
    await tester.tap(find.text('Bookmark selection'));
    await tester.pumpAndSettle();
    final b = settings.bookmarks.single;
    expect(b.kind, BookmarkKind.table);
    expect(b.rows, ['u4-r1', 'u4-r2']);
    expect(b.cols, ['u4-c1']);
  });

  testWidgets('table: tapping a header picks its column; Clear clears', (
    tester,
  ) async {
    await pumpApp(tester);
    await openSecondSection(tester);
    await tester.ensureVisible(find.text('Colour'));
    await tester.tap(find.text('Colour'));
    await tester.pumpAndSettle();
    expect(find.text('Bookmark selection'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear selection'));
    await tester.pumpAndSettle();
    expect(find.text('Bookmark selection'), findsNothing);
  });

  testWidgets('table: full screen keeps the table and its selection', (
    tester,
  ) async {
    await pumpApp(tester);
    await openSecondSection(tester);
    await tester.ensureVisible(find.text('Value'));
    await tester.tap(find.text('Value'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Show the table full screen'));
    await tester.pumpAndSettle();
    expect(find.text('54 parale'), findsOneWidget);
    expect(find.text('Bookmark selection'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a table bookmark reopens with its selection', (tester) async {
    final (_, settings) = await pumpApp(tester);
    await settings.addBookmark(
      const Bookmark(
        artefactId: 's2',
        kind: BookmarkKind.table,
        anchor: 'u4',
        rows: ['u4-r2'],
        cols: [],
        label: 'Table selection: 1 rows, 2 columns',
        created: 1,
      ),
    );
    await tester.pumpAndSettle();
    await tapTooltip(tester, 'Contents');
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Table selection: 1 rows, 2 columns'));
    await tester.pumpAndSettle();
    expect(find.text('Bookmark selection'), findsOneWidget); // restored
  });

  testWidgets('long-press bookmarks a passage, with Undo', (tester) async {
    final (_, settings) = await pumpApp(tester);
    await tester.longPress(find.text('The first stamps of Moldavia.'));
    await tester.pumpAndSettle();
    expect(settings.bookmarks.single.kind, BookmarkKind.passage);
    expect(settings.bookmarks.single.anchor, 'u1');
    expect(find.text('Passage bookmarked'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(settings.bookmarks, isEmpty);
  });

  testWidgets('image viewer: numbered, prev/next, two remote modes', (
    tester,
  ) async {
    final (_, settings) = await pumpApp(tester);
    await tapTooltip(tester, 'Contents');
    await tester.tap(find.text('Images'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('1. Figure 1'));
    await tester.pumpAndSettle();
    expect(find.text('Image 1 of 2'), findsOneWidget);
    // Fitted: Right is the next image.
    await press(tester, LogicalKeyboardKey.arrowRight);
    expect(find.text('Image 2 of 2'), findsOneWidget);
    // Select zooms; zoomed, Left pans instead of paging.
    await press(tester, LogicalKeyboardKey.select);
    expect(find.byTooltip('Fit to screen'), findsOneWidget);
    await press(tester, LogicalKeyboardKey.arrowLeft);
    expect(find.text('Image 2 of 2'), findsOneWidget);
    // Back leaves zoom first, then closes the viewer.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Image 2 of 2'), findsOneWidget);
    await tester.tap(find.byTooltip('Bookmark this image'));
    await tester.pumpAndSettle();
    expect(settings.bookmarks.single.kind, BookmarkKind.image);
    expect(settings.bookmarks.single.anchor, 'media__b');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Image 2 of 2'), findsNothing);
  });

  testWidgets('TV: search uses the in-app keyboard', (tester) async {
    await pumpApp(tester, size: tv, device: DeviceKind.tv);
    await tapTooltip(tester, 'Search');
    expect(find.byType(TvKeyboard), findsOneWidget);
    for (final k in ['r', 'e', 'd']) {
      await tester.tap(find.byKey(ValueKey('tv-key-$k')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Carmine red'), findsOneWidget);
  });

  testWidgets('unknown device: a keyboard button opens the in-app keyboard', (
    tester,
  ) async {
    await pumpApp(tester, size: tabletLandscape, device: DeviceKind.other);
    await tapTooltip(tester, 'Search');
    expect(find.byType(TvKeyboard), findsNothing);
    await tapTooltip(tester, 'Show the on-screen keyboard');
    expect(find.byType(TvKeyboard), findsOneWidget);
  });

  testWidgets('phone: no in-app keyboard', (tester) async {
    await pumpApp(tester);
    await tapTooltip(tester, 'Search');
    expect(find.byType(TvKeyboard), findsNothing);
    expect(find.byTooltip('Show the on-screen keyboard'), findsNothing);
  });

  testWidgets('TV: 10-foot type and overscan margins lay out cleanly', (
    tester,
  ) async {
    await pumpApp(tester, size: tv, device: DeviceKind.tv);
    expect(find.byType(MenuRail), findsOneWidget);
    expect(
      MediaQuery.textScalerOf(tester.element(find.byType(MenuRail))).scale(10),
      closeTo(16, 0.01),
    );
    expect(tester.takeException(), isNull);
  });

  test('TV-like devices: TV and unknown', () {
    expect(DeviceKind.tv.tvLike, isTrue);
    expect(DeviceKind.other.tvLike, isTrue);
    expect(DeviceKind.tablet.tvLike, isFalse);
  });
}
