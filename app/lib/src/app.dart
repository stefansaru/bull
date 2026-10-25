// The app root: theme, localisation, TV key mapping, state restoration.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import 'content/book.dart';
import 'settings.dart';
import 'speech/read_aloud.dart';
import 'speech/speech_service.dart';
import 'theme.dart';
import 'ui/scope.dart';
import 'ui/shell.dart';

export 'theme.dart' show buildTheme;

class BullApp extends StatefulWidget {
  const BullApp({
    super.key,
    required this.book,
    required this.settings,
    this.speech,
  });

  final Book book;
  final Settings settings;

  /// The text-to-speech engine; tests pass a fake.
  final SpeechService? speech;

  @override
  State<BullApp> createState() => _BullAppState();
}

class _BullAppState extends State<BullApp> {
  late final _readAloud = ReadAloud(widget.speech ?? DeviceSpeech());

  @override
  void dispose() {
    _readAloud.stop();
    _readAloud.dispose();
    super.dispose();
  }

  /// Where the book opens: the last page read, else the first section (owner
  /// ruling 2026-10-25).
  String get _startId {
    final last = widget.settings.lastSection;
    if (last != null && widget.book.section(last) != null) return last;
    return widget.book.sections.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    return AppScope(
      book: widget.book,
      settings: settings,
      child: Speech(
        reader: _readAloud,
        child: ListenableBuilder(
          listenable: settings,
          builder: (context, _) => MaterialApp(
            restorationScopeId: 'app',
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            locale: Locale(settings.language),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: buildTheme(Brightness.light, settings.vision),
            darkTheme: buildTheme(Brightness.dark, settings.vision),
            themeMode: themeModeOf(settings.theme),
            shortcuts: {
              ...WidgetsApp.defaultShortcuts,
              // TV remotes send "select" for the centre key (APP-ADP-002).
              const SingleActivator(LogicalKeyboardKey.select):
                  const ActivateIntent(),
            },
            home: ReaderShell(initialId: _startId),
          ),
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
