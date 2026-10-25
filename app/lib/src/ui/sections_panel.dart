// The Sections window (UIC-NAV-01a): the table of contents, then the Indexes, then
// Favorites and Recently visited — every list of the book has an entry point here.
// Shown as its own window in portrait and narrow landscape, as a pane when wide.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../content/book.dart';
import 'artefact_view.dart';
import 'scope.dart';
import 'shell.dart';

class SectionsPanel extends StatelessWidget {
  const SectionsPanel({super.key, required this.currentId, this.onChosen});

  final String currentId;

  /// Called after the reader picks something (closes the window).
  final VoidCallback? onChosen;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final book = scope.book;
    final lang = scope.lang;
    final l = AppLocalizations.of(context);
    final reader = Reader.of(context);
    final last = book.section(scope.settings.lastSection ?? '');
    final current = book.section(currentId);

    void read(String id) {
      onChosen?.call();
      reader.read(id);
    }

    void open(String id) {
      onChosen?.call();
      reader.open(id);
    }

    final indexIcons = {
      'index/images': Icons.photo_library_outlined,
      'index/abbreviations': Icons.short_text,
      'index/colours': Icons.palette_outlined,
      'index/calendars': Icons.calendar_month_outlined,
    };
    final recents = [
      for (final id in scope.settings.recents)
        if (book.artefact(id) != null) book.artefact(id)!,
    ];

    return ListView(
      key: const PageStorageKey('sections'),
      children: [
        if (last != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.bookmark),
                title: Text(l.continueReading),
                subtitle: Text(
                  pick(last.title, lang),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => read(last.id),
              ),
            ),
          ),
        for (final chapter in book.chapters)
          ExpansionTile(
            key: PageStorageKey('chapter-${chapter.id}'),
            title: Text(chapterTitle(book, chapter, lang)),
            initiallyExpanded: current?.chapter == chapter.id,
            children: [
              for (final s in book.sectionsOf(chapter))
                ListTile(
                  dense: true,
                  selected: s.id == currentId,
                  contentPadding: EdgeInsets.only(
                    left: 16.0 + 12 * (s.level - 1),
                    right: 16,
                  ),
                  title: Text(pick(s.title, lang)),
                  onTap: () => read(s.id),
                ),
            ],
          ),
        const Divider(),
        _Header(l.indexes),
        for (final index in book.indexes)
          ListTile(
            leading: Icon(indexIcons[index.id] ?? Icons.list),
            title: Text(pick(index.title, lang)),
            selected: index.id == currentId,
            onTap: () => open(index.id),
          ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.star_outline),
          title: Text(l.favorites),
          onTap: () {
            onChosen?.call();
            openFavorites(context, reader);
          },
        ),
        if (recents.isNotEmpty)
          ExpansionTile(
            key: const PageStorageKey('recents'),
            leading: const Icon(Icons.history),
            title: Text(l.recentlyVisited),
            children: [
              for (final a in recents)
                ListTile(
                  dense: true,
                  title: Text(
                    pick(a.title, lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => open(a.id),
                ),
            ],
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
    child: Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    ),
  );
}

/// The type label used by search filters and the favorites list.
String artefactTypeLabel(AppLocalizations l, Artefact a) => switch (a) {
  Section _ => l.typeNarrative,
  Entity e => groupLabel(l, e.group),
  BookImage _ => l.images,
  IndexInfo _ => l.indexes,
  _ => '',
};
