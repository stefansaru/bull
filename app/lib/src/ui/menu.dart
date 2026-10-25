// The more menu (UIC-NAV-02): Audio, Language, Help, Colours, Favorites, Privacy
// policy. Each entry opens its own subwindow in one step — no stacks of windows.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../settings.dart';
import 'scope.dart';
import 'shell.dart';
import 'speech_controls.dart';
import 'tour.dart';

/// Shown in the app and on the store listing (H-APP-PRV-001). See TODO.md: the page
/// must be published before the first release.
const privacyPolicyUrl = 'https://jini.solutions/bull/privacy';

/// Language rows as in Amethyst: code · name · flag · country (UIC-NAV-04).
const languageRows = {
  'en': ('English', '🇬🇧', 'United Kingdom'),
  'ro': ('Română', '🇷🇴', 'România'),
  'fr': ('Français', '🇫🇷', 'France'),
  'de': ('Deutsch', '🇩🇪', 'Deutschland'),
};

Future<void> showMenuWindow(
  BuildContext context,
  ReaderActions actions,
  TourKeys keys,
  LayoutMode mode,
) async {
  final l = AppLocalizations.of(context);
  final choice = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final (id, icon, label) in [
            ('readAloud', Icons.record_voice_over_outlined, l.readAloud),
            ('audio', Icons.volume_up_outlined, l.audio),
            ('language', Icons.translate, l.language),
            ('help', Icons.help_outline, l.help),
            ('colours', Icons.contrast, l.colourSettings),
            ('favorites', Icons.star_outline, l.favorites),
            ('privacy', Icons.privacy_tip_outlined, l.privacyPolicy),
            ('about', Icons.info_outline, l.about),
          ])
            ListTile(
              autofocus: id == 'readAloud',
              leading: Icon(icon),
              title: Text(label),
              onTap: () => Navigator.of(ctx).pop(id),
            ),
        ],
      ),
    ),
  );
  if (!context.mounted || choice == null) return;
  switch (choice) {
    case 'readAloud':
      await startReadAloud(context, actions);
    case 'audio':
      await showDialog<void>(
        context: context,
        builder: (_) => const AudioWindow(),
      );
    case 'language':
      await showDialog<void>(
        context: context,
        builder: (_) => const LanguageWindow(),
      );
    case 'help':
      await showDialog<void>(
        context: context,
        builder: (_) => HelpWindow(keys: keys, mode: mode, shell: context),
      );
    case 'colours':
      await showDialog<void>(
        context: context,
        builder: (_) => const ColoursWindow(),
      );
    case 'favorites':
      openFavorites(context, actions);
    case 'privacy':
      await launchUrl(
        Uri.parse(privacyPolicyUrl),
        mode: LaunchMode.externalApplication,
      );
    case 'about':
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.appTitle),
          content: Text('${l.publisher}\n\n${l.privacySummary}'),
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
}

class _Window extends StatelessWidget {
  const _Window({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title),
    contentPadding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
    content: SizedBox(
      width: 420,
      child: ListView(shrinkWrap: true, children: children),
    ),
    actions: [
      TextButton(
        autofocus: true,
        onPressed: () => Navigator.of(context).pop(),
        child: Text(AppLocalizations.of(context).close),
      ),
    ],
  );
}

/// Audio (UIC-NAV-03), modelled on Amethyst's audio window.
class AudioWindow extends StatelessWidget {
  const AudioWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    final l = AppLocalizations.of(context);
    return _Window(
      title: l.audio,
      children: [
        SwitchListTile(
          title: Text(l.soundEffects),
          value: settings.soundEffects,
          onChanged: settings.setSoundEffects,
        ),
        const SpeechSettings(),
      ],
    );
  }
}

/// Language and country, reorderable (UIC-NAV-04). Drag on touch; Move up / Move down
/// buttons do the same from a remote.
class LanguageWindow extends StatelessWidget {
  const LanguageWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final settings = scope.settings;
    final l = AppLocalizations.of(context);
    final order = settings.languageOrder;

    void move(int from, int to) {
      final list = [...order];
      final item = list.removeAt(from);
      list.insert(to.clamp(0, list.length), item);
      settings.setLanguageOrder(list);
    }

    return AlertDialog(
      title: Text(l.language),
      contentPadding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
      content: SizedBox(
        width: 460,
        height: 72.0 * order.length + 8,
        child: ReorderableListView(
          buildDefaultDragHandles: false,
          onReorderItem: move,
          children: [
            for (final (i, lang) in order.indexed)
              ListTile(
                key: ValueKey(lang),
                selected: lang == scope.lang,
                leading: ReorderableDragStartListener(
                  index: i,
                  child: const Icon(Icons.drag_handle),
                ),
                title: Text(
                  '${lang.toUpperCase()} · ${languageRows[lang]?.$1 ?? lang} · '
                  '${languageRows[lang]?.$2 ?? ''} · ${languageRows[lang]?.$3 ?? ''}',
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  settings.setLanguage(lang);
                  Navigator.of(context).pop();
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: l.moveUp,
                      onPressed: i == 0 ? null : () => move(i, i - 1),
                      icon: const Icon(Icons.arrow_upward),
                    ),
                    IconButton(
                      tooltip: l.moveDown,
                      onPressed: i == order.length - 1
                          ? null
                          : () => move(i, i + 1),
                      icon: const Icon(Icons.arrow_downward),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.close),
        ),
      ],
    );
  }
}

/// Help (UIC-NAV-05): the tour of the controls, and short topics.
class HelpWindow extends StatelessWidget {
  const HelpWindow({
    super.key,
    required this.keys,
    required this.mode,
    required this.shell,
  });

  final TourKeys keys;
  final LayoutMode mode;
  final BuildContext shell;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget topic(String title, String body) => ExpansionTile(
      title: Text(title),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      children: [Text(body)],
    );
    return _Window(
      title: l.help,
      children: [
        ListTile(
          leading: const Icon(Icons.tour_outlined),
          title: Text(l.helpTour),
          onTap: () {
            Navigator.of(context).pop();
            startTour(shell, keys, mode);
          },
        ),
        topic(l.helpLinksTitle, l.helpLinksBody),
        topic(l.helpDatesTitle, l.helpDatesBody),
        topic(l.helpFavoritesTitle, l.helpFavoritesBody),
        topic(l.helpImagesTitle, l.helpImagesBody),
        topic(l.helpTablesTitle, l.helpTablesBody),
      ],
    );
  }
}

/// Colours (UIC-NAV-06): theme × vision mode.
class ColoursWindow extends StatelessWidget {
  const ColoursWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return _Window(
      title: l.colourSettings,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(l.theme, style: theme.textTheme.titleSmall),
        ),
        RadioGroup<ThemeChoice>(
          groupValue: settings.theme,
          onChanged: (v) {
            if (v != null) settings.setTheme(v);
          },
          child: Column(
            children: [
              for (final (v, label) in [
                (ThemeChoice.automatic, l.themeAutomatic),
                (ThemeChoice.light, l.themeLight),
                (ThemeChoice.dark, l.themeDark),
              ])
                RadioListTile<ThemeChoice>(value: v, title: Text(label)),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(l.visionMode, style: theme.textTheme.titleSmall),
        ),
        RadioGroup<VisionMode>(
          groupValue: settings.vision,
          onChanged: (v) {
            if (v != null) settings.setVision(v);
          },
          child: Column(
            children: [
              for (final (v, label, note) in [
                (VisionMode.standard, l.visionStandard, ''),
                (
                  VisionMode.redGreenSafe,
                  l.visionRedGreen,
                  l.visionRedGreenNote,
                ),
                (VisionMode.tritanSafe, l.visionTritan, l.visionTritanNote),
                (
                  VisionMode.grayscale,
                  l.visionGrayscale,
                  l.visionGrayscaleNote,
                ),
              ])
                RadioListTile<VisionMode>(
                  value: v,
                  title: Text(label),
                  subtitle: note.isEmpty ? null : Text(note),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            l.visionKeepsEvidence,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
