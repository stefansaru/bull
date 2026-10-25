// Favorites (UIC-FAV): Continue reading on top, then everything starred or bookmarked,
// grouped by artefact — an artefact with several bookmarks is an expandable branch.
// Delete one bookmark, all of one artefact, or all. Search here is the book search
// with "favorites only" applied (UIC-FAV-06).
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../content/book.dart';
import '../settings.dart';
import 'scope.dart';
import 'search_page.dart';
import 'sections_panel.dart';
import 'shell.dart';

String bookmarkLabel(AppLocalizations l, Bookmark b) => switch (b.kind) {
  BookmarkKind.artefact => l.wholePage,
  BookmarkKind.passage => b.label.isEmpty ? l.passage : b.label,
  BookmarkKind.table => l.tableSelection(b.rows.length, b.cols.length),
  BookmarkKind.image => b.label.isEmpty ? l.image : b.label,
};

IconData bookmarkIcon(BookmarkKind k) => switch (k) {
  BookmarkKind.artefact => Icons.star,
  BookmarkKind.passage => Icons.format_quote,
  BookmarkKind.table => Icons.table_chart_outlined,
  BookmarkKind.image => Icons.image_outlined,
};

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  Future<bool> _confirm(BuildContext context, String message) async {
    final l = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            content: Text(message),
            actions: [
              TextButton(
                autofocus: true,
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l.delete),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final settings = scope.settings;
    final book = scope.book;
    final l = AppLocalizations.of(context);
    final reader = Reader.of(context);
    final lang = scope.lang;
    final groups = <String, List<Bookmark>>{};
    for (final b in settings.bookmarks) {
      groups.putIfAbsent(b.artefactId, () => []).add(b);
    }
    final last = book.section(settings.lastSection ?? '');

    void go(String id, {String anchor = ''}) {
      Navigator.of(context).pop();
      if (book.artefact(id) != null) reader.open(id, anchor: anchor);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.favorites),
        actions: [
          IconButton(
            tooltip: l.searchFavorites,
            icon: const Icon(Icons.search),
            onPressed: () => pushWindow<void>(
              context,
              () => const SearchPage(favoritesOnly: true),
            ),
          ),
          if (groups.isNotEmpty)
            IconButton(
              tooltip: l.deleteAll,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () async {
                if (await _confirm(context, l.confirmDeleteAll)) {
                  await settings.removeAllBookmarks();
                }
              },
            ),
        ],
      ),
      body: ListView(
        children: [
          if (last != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: Text(l.continueReading),
                  subtitle: Text(pick(last.title, lang)),
                  onTap: () {
                    Navigator.of(context).pop();
                    reader.read(last.id);
                  },
                ),
              ),
            ),
          if (groups.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l.noFavorites, textAlign: TextAlign.center),
            ),
          for (final MapEntry(key: id, value: marks) in groups.entries)
            _ArtefactNode(
              artefact: book.artefact(id),
              marks: marks,
              onOpen: go,
              onDeleteAll: () async {
                final title = pick(book.artefact(id)?.title ?? const {}, lang);
                if (await _confirm(context, l.confirmDeleteFor(title))) {
                  await settings.removeBookmarksOf(id);
                }
              },
              onDelete: settings.removeBookmark,
            ),
        ],
      ),
    );
  }
}

class _ArtefactNode extends StatelessWidget {
  const _ArtefactNode({
    required this.artefact,
    required this.marks,
    required this.onOpen,
    required this.onDeleteAll,
    required this.onDelete,
  });

  /// Null when the bookmarked content is no longer in the book.
  final Artefact? artefact;
  final List<Bookmark> marks;
  final void Function(String id, {String anchor}) onOpen;
  final VoidCallback onDeleteAll;
  final Future<void> Function(Bookmark) onDelete;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final a = artefact;
    final title = a == null ? l.noLongerAvailable : pick(a.title, scope.lang);
    final subtitle = a == null ? '' : artefactTypeLabel(l, a);
    final deleteAll = IconButton(
      tooltip: l.deleteAllFor,
      icon: const Icon(Icons.delete_outline),
      onPressed: onDeleteAll,
    );
    if (marks.length == 1 && marks.single.kind == BookmarkKind.artefact) {
      return ListTile(
        leading: const Icon(Icons.star),
        title: Text(title),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        enabled: a != null,
        onTap: a == null ? null : () => onOpen(a.id),
        trailing: deleteAll,
      );
    }
    return ExpansionTile(
      initiallyExpanded: true,
      leading: const Icon(Icons.folder_outlined),
      title: Text(title),
      subtitle: Text('$subtitle · ${l.bookmarksCount(marks.length)}'),
      trailing: deleteAll,
      children: [
        for (final b in marks)
          ListTile(
            contentPadding: const EdgeInsets.only(left: 40, right: 8),
            leading: Icon(bookmarkIcon(b.kind)),
            title: Text(bookmarkLabel(l, b)),
            enabled: a != null,
            onTap: a == null ? null : () => onOpen(a.id, anchor: b.anchor),
            trailing: IconButton(
              tooltip: l.deleteBookmark,
              icon: const Icon(Icons.close),
              onPressed: () => onDelete(b),
            ),
          ),
      ],
    );
  }
}
