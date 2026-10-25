// Adaptive layout (APP-ADP-001, UIC-LAY), accessibility (APP-ACC-001), TV remote
// navigation (APP-ADP-002, UIC-PLT-04).
import 'package:capdebour/src/ui/artefact_view.dart';
import 'package:capdebour/src/ui/sections_panel.dart';
import 'package:capdebour/src/ui/shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('phone portrait: the top menu, the date line and the title', (
    tester,
  ) async {
    await pumpApp(tester, size: phonePortrait);
    expect(find.byType(TopMenu), findsOneWidget);
    expect(find.byType(MenuRail), findsNothing);
    for (final tip in ['Back', 'Contents', 'Add to favorites', 'Search']) {
      expect(find.byTooltip(tip), findsOneWidget);
    }
    expect(find.byTooltip('More options'), findsOneWidget);
    expect(find.byTooltip('Show title'), findsNothing); // landscape only
    expect(find.byType(ArtefactHeading), findsOneWidget);
    expect(find.text('The first stamps of Moldavia.'), findsOneWidget);
  });

  testWidgets('tablet portrait: top menu, single pane', (tester) async {
    await pumpApp(tester, size: tabletPortrait);
    expect(find.byType(TopMenu), findsOneWidget);
    expect(find.byType(SectionsPanel), findsNothing);
  });

  testWidgets('phone landscape: the rail, and the title behind its button', (
    tester,
  ) async {
    await pumpApp(tester, size: phoneLandscape);
    expect(find.byType(MenuRail), findsOneWidget);
    expect(find.byType(SectionsPanel), findsNothing);
    expect(find.byType(ArtefactHeading), findsNothing); // hidden by default
    await tapTooltip(tester, 'Show title');
    expect(find.byType(ArtefactHeading), findsOneWidget);
    await tapTooltip(tester, 'Hide title');
    expect(find.byType(ArtefactHeading), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final (name, size) in [
    ('tablet landscape', tabletLandscape),
    ('TV', tv),
  ]) {
    testWidgets('$name: rail, Sections pane beside the page', (tester) async {
      await pumpApp(tester, size: size);
      expect(find.byType(MenuRail), findsOneWidget);
      expect(find.byType(SectionsPanel), findsOneWidget);
      expect(find.text('The first stamps of Moldavia.'), findsOneWidget);
      // The Sections button hides and shows the pane.
      await tapTooltip(tester, 'Contents');
      expect(find.byType(SectionsPanel), findsNothing);
      await tapTooltip(tester, 'Contents');
      expect(find.byType(SectionsPanel), findsOneWidget);
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
    await tapTooltip(tester, 'Contents');
    expect(find.text('Indexes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('accessibility guidelines on an artefact page', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('links are semantic links (TalkBack can list them)', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester);
    expect(
      find.semantics.byPredicate(
        (n) =>
            n.getSemanticsData().flagsCollection.isLink &&
            n.label == 'carmine red',
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('TV: the remote alone reaches a link, previews it, opens it', (
    tester,
  ) async {
    await pumpApp(tester, size: tv);
    Future<void> press(LogicalKeyboardKey key) async {
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
    }

    bool focusedOnLinkParagraph() {
      final ctx = FocusManager.instance.primaryFocus?.context;
      if (ctx == null) return false;
      return find
          .descendant(
            of: find.byWidget(ctx.widget),
            matching: find.textContaining('Printed in', findRichText: true),
          )
          .evaluate()
          .isNotEmpty;
    }

    for (var i = 0; i < 60 && !focusedOnLinkParagraph(); i++) {
      await press(
        i.isEven ? LogicalKeyboardKey.arrowDown : LogicalKeyboardKey.arrowRight,
      );
    }
    expect(focusedOnLinkParagraph(), isTrue);
    await press(LogicalKeyboardKey.select);
    // Two links in that paragraph: the remote offers the choice.
    expect(find.text('Links in this paragraph'), findsOneWidget);
    await tester.tap(find.text('Carmine red'));
    await tester.pumpAndSettle();
    expect(find.text('More'), findsOneWidget);
    await press(LogicalKeyboardKey.select); // More has the focus
    expect(find.text('Pantone 1807 — Carmine Red'), findsOneWidget);
  });
}
