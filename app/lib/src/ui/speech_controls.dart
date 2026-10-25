// Read-aloud controls (UIC-NAV-03): start from the more menu, a small bar while
// reading (previous paragraph · stop · next paragraph), and the speech rate.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../speech/read_aloud.dart';
import '../speech/speech_service.dart';
import 'menu.dart';
import 'scope.dart';

Future<void> startReadAloud(BuildContext context, ReaderActions actions) async {
  final scope = AppScope.of(context);
  final speech = Speech.of(context);
  final l = AppLocalizations.of(context);
  final artefact = scope.book.artefact(actions.currentId);
  if (artefact == null) return;
  final result = await speech.start(
    artefact,
    scope.lang,
    scope.settings.speechRate,
  );
  if (result == SpeechAvailability.available || !context.mounted) return;
  final language = languageRows[scope.lang]?.$1 ?? scope.lang;
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.readAloud),
      content: Text(
        '${l.readAloudUnavailable(language)}\n\n${l.readAloudSetup}',
      ),
      actions: [
        TextButton(
          autofocus: true,
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l.close),
        ),
      ],
    ),
  );
}

class SpeechSettings extends StatelessWidget {
  const SpeechSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    final l = AppLocalizations.of(context);
    return ListTile(
      title: Text(l.speechRate),
      subtitle: Slider(
        value: settings.speechRate,
        min: 0.2,
        max: 0.8,
        divisions: 6,
        label: settings.speechRate.toStringAsFixed(1),
        onChanged: settings.setSpeechRate,
      ),
    );
  }
}

/// Shown at the bottom of the page while reading aloud.
class ReadAloudBar extends StatelessWidget {
  const ReadAloudBar({super.key});

  @override
  Widget build(BuildContext context) {
    final speech = Speech.of(context);
    if (!speech.playing) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final rate = AppScope.of(context).settings.speechRate;
    return Material(
      elevation: 6,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: l.previousParagraph,
              onPressed: () => speech.step(-1, rate),
              icon: const Icon(Icons.skip_previous),
            ),
            IconButton(
              autofocus: true,
              tooltip: l.stopReading,
              onPressed: speech.stop,
              icon: const Icon(Icons.stop),
            ),
            IconButton(
              tooltip: l.nextParagraph,
              onPressed: () => speech.step(1, rate),
              icon: const Icon(Icons.skip_next),
            ),
            Text('${speech.index + 1} / ${speech.length}'),
          ],
        ),
      ),
    );
  }
}
