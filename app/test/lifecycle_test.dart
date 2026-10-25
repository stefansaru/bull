// Lifecycle baselines (APP-LIFE-001 refining H-APP-LIFE-001…005).
import 'package:capdebour/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('H-APP-LIFE-001 cold start opens the book at its first page', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('The first stamps of Moldavia.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('H-APP-LIFE-002 close and reopen returns to the last page read', (
    tester,
  ) async {
    final (book, settings) = await pumpApp(tester);
    await tester.scrollUntilVisible(find.text('Next'), 200);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(settings.lastSection, 's2');

    // Close: the widget tree goes away; reopen with the same stored preferences.
    await tester.pumpWidget(const SizedBox());
    final reopened = await settingsFor(book, {
      'lastSection': 's2',
      'language': 'en',
      'tourSeen': true,
    });
    await tester.pumpWidget(
      BullApp(book: book, settings: reopened, speech: FakeSpeech()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Because the aurochs head deserves it.'), findsOneWidget);
  });

  testWidgets('H-APP-LIFE-003 background and resume keeps the page open', (
    tester,
  ) async {
    await pumpApp(tester);
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
      await tester.pump();
    }
    expect(find.text('The first stamps of Moldavia.'), findsOneWidget);
  });

  testWidgets(
    'H-APP-LIFE-004 process death restores the page and the way back',
    (tester) async {
      await pumpApp(tester);
      await tapLink(tester, 'carmine red');
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.text('Pantone 1807 — Carmine Red'), findsOneWidget);

      await tester.restartAndRestore();
      expect(find.text('Pantone 1807 — Carmine Red'), findsOneWidget);
      await tapTooltip(tester, 'Back');
      expect(find.text('The first stamps of Moldavia.'), findsOneWidget);
    },
  );

  testWidgets('H-APP-LIFE-005 rotation keeps the page being read', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.scrollUntilVisible(find.text('Next'), 200);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await setSize(tester, phoneLandscape);
    await tester.pumpAndSettle();
    expect(find.text('Because the aurochs head deserves it.'), findsOneWidget);
    await setSize(tester, phonePortrait);
    await tester.pumpAndSettle();
    expect(find.text('Because the aurochs head deserves it.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('H-APP-LIFE-005 language change while reading keeps the place', (
    tester,
  ) async {
    final (_, settings) = await pumpApp(tester);
    await settings.setLanguage('ro');
    await tester.pumpAndSettle();
    expect(find.text('Primele mărci ale Moldovei.'), findsOneWidget);
  });
}
