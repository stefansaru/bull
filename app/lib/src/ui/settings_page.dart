// Settings: book language (APP-L10N-002), privacy (APP-PRV-001), about.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'scope.dart';

/// Shown in the app and on the store listing (H-APP-PRV-001). See TODO.md: the page
/// must be published before the first release.
const privacyPolicyUrl = 'https://jini.solutions/bull/privacy';

const _languageNames = {
  'en': 'English',
  'ro': 'Română',
  'fr': 'Français',
  'de': 'Deutsch',
};

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ListTile(title: Text(l.language, style: theme.textTheme.titleMedium)),
        RadioGroup<String>(
          groupValue: scope.lang,
          onChanged: (v) {
            if (v != null) scope.settings.setLanguage(v);
          },
          child: Column(
            children: [
              for (final lang in scope.settings.available)
                RadioListTile<String>(
                  value: lang,
                  title: Text(_languageNames[lang] ?? lang),
                ),
            ],
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: Text(l.privacyPolicy),
          subtitle: Text('${l.privacySummary}\n$privacyPolicyUrl'),
          isThreeLine: true,
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(l.about),
          subtitle: Text(l.publisher),
        ),
      ],
    );
  }
}
