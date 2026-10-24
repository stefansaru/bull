// Adaptive layout per declared form factor (APP-ADP-001), accessibility (APP-ACC-001),
// TV remote navigation (APP-ADP-002).
import 'package:capdebour/src/ui/section_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('phone portrait: bottom navigation, reader opens as a page', (
    tester,
  ) async {
    await pumpApp(tester, size: phonePortrait);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(SectionView), findsNothing);
    await openFirstSection(tester);
    expect(find.byType(SectionView), findsOneWidget);
  });

  testWidgets('tablet portrait: navigation rail, single pane', (tester) async {
    await pumpApp(tester, size: tabletPortrait);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(SectionView), findsNothing);
  });

  for (final (name, size) in [
    ('tablet landscape', tabletLandscape),
    ('TV', tv),
    ('phone landscape', phoneLandscape),
  ]) {
    testWidgets('$name: two panes, contents beside the reader', (tester) async {
      await pumpApp(tester, size: size);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(SectionView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('large text (200 %) does not overflow on a phone', (
    tester,
  ) async {
    await setSize(tester, phonePortrait);
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(tester);
    await openFirstSection(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('accessibility guidelines on the contents screen', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('TV: the remote alone can open a chapter and a section', (
    tester,
  ) async {
    await pumpApp(tester, size: tv);
    // Move focus into the contents with the D-pad and activate with "select".
    Future<void> press(LogicalKeyboardKey key) async {
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
    }

    String? focusedText() {
      final ctx = FocusManager.instance.primaryFocus?.context;
      if (ctx == null) return null;
      final texts = find.descendant(
        of: find.byWidget(ctx.widget),
        matching: find.byType(Text),
      );
      return texts.evaluate().isEmpty
          ? null
          : (texts.evaluate().first.widget as Text).data;
    }

    for (var i = 0; i < 12 && focusedText() != 'The Aurochs'; i++) {
      await press(LogicalKeyboardKey.arrowDown);
      if (focusedText() == null) await press(LogicalKeyboardKey.arrowRight);
    }
    expect(focusedText(), 'The Aurochs');
    await press(LogicalKeyboardKey.select); // expand the chapter
    await press(LogicalKeyboardKey.arrowDown);
    await press(LogicalKeyboardKey.select); // open its section
    expect(
      find.text('An extinct wild ox, symbol of Moldavia.'),
      findsOneWidget,
    );
  });
}
