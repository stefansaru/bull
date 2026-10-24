// The app root: theme, localisation, TV key mapping, state restoration.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import 'content/book.dart';
import 'settings.dart';
import 'ui/home_page.dart';
import 'ui/scope.dart';

/// Paper and ink of the 1858 stamps: cream laid paper, black and blue handstamps
/// (APP-UX-002 design tokens).
const _ink = Color(0xFF1E1E1E);
const _seed = Color(0xFF6B3A2A);

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  final light = brightness == Brightness.light;
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: light
        ? const Color(0xFFF7F1E3)
        : const Color(0xFF151311),
    textTheme: Typography.material2021(platform: TargetPlatform.android).black
        .apply(
          bodyColor: light ? _ink : null,
          displayColor: light ? _ink : null,
        )
        .merge(light ? null : Typography.material2021().white),
    // Keyboard and D-pad focus must always be visible (H-APP-ADP-002, H-APP-ACC-001).
    focusColor: scheme.primary.withValues(alpha: 0.24),
    visualDensity: VisualDensity.standard,
  );
}

class BullApp extends StatelessWidget {
  const BullApp({super.key, required this.book, required this.settings});

  final Book book;
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      book: book,
      settings: settings,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => MaterialApp(
          restorationScopeId: 'app',
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          locale: Locale(settings.language),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          shortcuts: {
            ...WidgetsApp.defaultShortcuts,
            // TV remotes send "select" for the centre key (APP-ADP-002).
            const SingleActivator(LogicalKeyboardKey.select):
                const ActivateIntent(),
          },
          home: const HomePage(),
        ),
      ),
    );
  }
}

/// Shown when the content bundle was not built (fresh clone without a wizard run).
class MissingContentApp extends StatelessWidget {
  const MissingContentApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: buildTheme(Brightness.light),
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              AppLocalizations.of(context).contentMissing,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ),
  );
}
