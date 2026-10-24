// Lifecycle baselines (APP-LIFE-001 refining H-APP-LIFE-001…005).
import 'package:capdebour/src/app.dart';
import 'package:capdebour/src/ui/section_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('H-APP-LIFE-001 cold start reaches the contents', (tester) async {
    await pumpApp(tester);
    expect(find.text("Bull's Head 1858"), findsOneWidget);
    expect(find.text('The Aurochs'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'H-APP-LIFE-002 close and reopen offers to continue where the reader was',
    (tester) async {
      final (book, settings) = await pumpApp(tester);
      await openFirstSection(tester);
      expect(settings.lastSection, 's1');

      // Close: the widget tree goes away; reopen with the same stored preferences.
      await tester.pumpWidget(const SizedBox());
      final reopened = await settingsFor(book, {
        'lastSection': 's1',
        'language': 'en',
      });
      await tester.pumpWidget(BullApp(book: book, settings: reopened));
      await tester.pumpAndSettle();
      expect(find.text('Continue reading'), findsOneWidget);
    },
  );

  testWidgets('H-APP-LIFE-003 background and resume keeps the reader open', (
    tester,
  ) async {
    await pumpApp(tester);
    await openFirstSection(tester);
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
    expect(find.byType(SectionView), findsOneWidget);
    expect(find.text('The first stamps of Moldavia.'), findsOneWidget);
  });

  testWidgets('H-APP-LIFE-004 process death restores the open section', (
    tester,
  ) async {
    await pumpApp(tester);
    await openFirstSection(tester);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Because the aurochs head deserves it.'), findsOneWidget);

    await tester.restartAndRestore();
    expect(find.byType(SectionView), findsOneWidget);
    expect(find.text('Because the aurochs head deserves it.'), findsOneWidget);
  });

  testWidgets('H-APP-LIFE-005 rotation keeps the section being read', (
    tester,
  ) async {
    await pumpApp(tester);
    await openFirstSection(tester);
    await setSize(tester, phoneLandscape);
    await tester.pumpAndSettle();
    expect(find.text('The first stamps of Moldavia.'), findsWidgets);
    await setSize(tester, phonePortrait);
    await tester.pumpAndSettle();
    expect(find.text('The first stamps of Moldavia.'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('H-APP-LIFE-005 language change while reading keeps the place', (
    tester,
  ) async {
    final (_, settings) = await pumpApp(tester);
    await openFirstSection(tester);
    await settings.setLanguage('ro');
    await tester.pumpAndSettle();
    expect(find.text('Primele mărci ale Moldovei.'), findsOneWidget);
  });
}
