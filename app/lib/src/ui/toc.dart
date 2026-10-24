// Table of contents with a one-tap "continue reading" (APP-UX-001: the primary task,
// reading, is at most two interactions from launch).
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../content/book.dart';
import 'scope.dart';

class TableOfContents extends StatelessWidget {
  const TableOfContents({super.key, required this.onOpen, this.selected});

  final ValueChanged<String> onOpen;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final book = scope.book;
    final lang = scope.lang;
    final l = AppLocalizations.of(context);
    final last = book.section(scope.settings.lastSection ?? '');
    return ListView(
      key: const PageStorageKey('toc'),
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
                onTap: () => onOpen(last.id),
              ),
            ),
          ),
        for (final chapter in book.chapters)
          ExpansionTile(
            key: PageStorageKey('chapter-${chapter.id}'),
            title: Text(_chapterTitle(book, chapter, lang)),
            initiallyExpanded: chapter.sectionIds.contains(selected),
            children: [
              for (final s in book.sectionsOf(chapter))
                ListTile(
                  dense: true,
                  selected: s.id == selected,
                  contentPadding: EdgeInsets.only(
                    left: 16.0 + 12 * (s.level - 1),
                    right: 16,
                  ),
                  title: Text(pick(s.title, lang)),
                  onTap: () => onOpen(s.id),
                ),
            ],
          ),
      ],
    );
  }

  /// The chapter's first heading in the reader's language, else the wiki's label.
  String _chapterTitle(Book book, Chapter chapter, String lang) {
    final first = book.sectionsOf(chapter).firstOrNull;
    if (first != null && first.level == 1) return pick(first.title, lang);
    return chapter.label;
  }
}
