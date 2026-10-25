// The preview popup (UIC-LNK-02..04): a brief description and More. Initial focus is
// on More, so a remote user presses Select once more to go deeper, or Back to stay.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../content/book.dart';
import 'scope.dart';

/// Returns true when the reader chose More.
Future<bool> showPreview(BuildContext context, Artefact artefact) async {
  final scope = AppScope.of(context);
  final l = AppLocalizations.of(context);
  final title = pick(artefact.title, scope.lang);
  final summary = previewText(artefact, scope.lang);
  final more = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      semanticLabel: l.previewOf(title),
      title: Text(title),
      content: summary.isEmpty
          ? null
          : SingleChildScrollView(child: Text(summary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l.close),
        ),
        FilledButton(
          autofocus: true,
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l.more),
        ),
      ],
    ),
  );
  return more ?? false;
}

/// The artefact's `summary`, else its first paragraph (UIC-LNK-04).
String previewText(Artefact a, String lang) {
  final s = pick(a.summary, lang);
  if (s.isNotEmpty) return s;
  for (final u in a.units) {
    if (u.kind == 'text' || u.kind == 'quad') {
      final p = u
          .plain(lang)
          .split('\n')
          .firstWhere((x) => x.trim().length > 20, orElse: () => '');
      if (p.isNotEmpty) return p;
    }
  }
  return '';
}
