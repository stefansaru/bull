// Search (UIC-SRC): one search for the whole book, in the reader's language. Filters
// live in their own subwindow; the button shows how many are applied, and applied
// filters stay visible as chips above the results. The favorites window reuses this
// page with "favorites only" already applied (UIC-FAV-06). The book is small enough
// to search in memory.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../content/book.dart';
import '../platform.dart';
import 'artefact_view.dart';
import 'scope.dart';
import 'sections_panel.dart';
import 'tv_text_field.dart';

/// The type filter key of an artefact: "narrative" or the entity's group.
String typeKey(Artefact a) => switch (a) {
  Section _ => 'narrative',
  Entity e => e.group,
  _ => '',
};

class SearchFilters {
  const SearchFilters({
    this.types = const {},
    this.chapter,
    this.favoritesOnly = false,
  });

  final Set<String> types;
  final String? chapter;
  final bool favoritesOnly;

  int get count =>
      (types.isEmpty ? 0 : 1) +
      (chapter == null ? 0 : 1) +
      (favoritesOnly ? 1 : 0);

  SearchFilters copyWith({
    Set<String>? types,
    String? chapter,
    bool clearChapter = false,
    bool? favoritesOnly,
  }) => SearchFilters(
    types: types ?? this.types,
    chapter: clearChapter ? null : chapter ?? this.chapter,
    favoritesOnly: favoritesOnly ?? this.favoritesOnly,
  );
}

class SearchHit {
  const SearchHit(this.artefact, this.snippet);
  final Artefact artefact;
  final String snippet;
}

List<SearchHit> searchBook(
  Book book,
  String lang,
  String query,
  SearchFilters f,
  Set<String> favorites,
) {
  final q = query.trim().toLowerCase();
  final out = <SearchHit>[];
  final candidates = <(Artefact, String)>[
    for (final s in book.sections) (s, s.plainText(lang)),
    for (final e in book.entities) (e, e.plainText(lang)),
  ];
  for (final (a, text) in candidates) {
    if (f.types.isNotEmpty && !f.types.contains(typeKey(a))) continue;
    if (f.chapter != null && (a is! Section || a.chapter != f.chapter)) {
      continue;
    }
    if (f.favoritesOnly && !favorites.contains(a.id)) continue;
    if (q.length < 2) {
      if (f.favoritesOnly) out.add(SearchHit(a, ''));
      continue;
    }
    final i = text.toLowerCase().indexOf(q);
    if (i < 0) continue;
    final start = (i - 40).clamp(0, text.length);
    final end = (i + q.length + 60).clamp(0, text.length);
    out.add(
      SearchHit(a, '…${text.substring(start, end).replaceAll('\n', ' ')}…'),
    );
  }
  return out;
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.favoritesOnly = false});

  final bool favoritesOnly;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _query = TextEditingController();
  late SearchFilters _filters = SearchFilters(
    favoritesOnly: widget.favoritesOnly,
  );

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _editFilters() async {
    final result = await showModalBottomSheet<SearchFilters>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FilterSheet(initial: _filters),
    );
    if (result != null) setState(() => _filters = result);
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final reader = Reader.of(context);
    final book = scope.book;
    final results = searchBook(
      book,
      scope.lang,
      _query.text,
      _filters,
      scope.settings.favoriteIds,
    );
    final chapter = book.chapters
        .where((c) => c.id == _filters.chapter)
        .firstOrNull;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.favoritesOnly ? l.searchFavorites : l.search),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _editFilters,
              icon: const Icon(Icons.filter_list),
              label: Text(l.filtersCount(_filters.count)),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, box) {
          final query = <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: TvTextField(
                controller: _query,
                hint: l.searchHint,
                onChanged: (_) => setState(() {}),
              ),
            ),
            if (_filters.count > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final t in _filters.types)
                      InputChip(
                        label: Text(
                          t == 'narrative' ? l.typeNarrative : groupLabel(l, t),
                        ),
                        onDeleted: () => setState(
                          () => _filters = _filters.copyWith(
                            types: {..._filters.types}..remove(t),
                          ),
                        ),
                      ),
                    if (chapter != null)
                      InputChip(
                        label: Text(chapterTitle(book, chapter, scope.lang)),
                        onDeleted: () => setState(
                          () =>
                              _filters = _filters.copyWith(clearChapter: true),
                        ),
                      ),
                    if (_filters.favoritesOnly)
                      InputChip(
                        label: Text(l.favoritesOnly),
                        onDeleted: () => setState(
                          () => _filters = _filters.copyWith(
                            favoritesOnly: false,
                          ),
                        ),
                      ),
                    ActionChip(
                      label: Text(l.clearFilters),
                      onPressed: () =>
                          setState(() => _filters = const SearchFilters()),
                    ),
                  ],
                ),
              ),
          ];
          final Widget list = results.isEmpty && _query.text.trim().length >= 2
              ? Center(child: Text(l.noResults))
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, i) {
                    final hit = results[i];
                    return ListTile(
                      title: Text(pick(hit.artefact.title, scope.lang)),
                      subtitle: Text(
                        [
                          artefactTypeLabel(l, hit.artefact),
                          if (hit.snippet.isNotEmpty) hit.snippet,
                        ].join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        reader.open(hit.artefact.id);
                      },
                    );
                  },
                );
          // With the in-app keyboard on a wide TV screen, the keyboard sits beside
          // the results instead of above them.
          if (scope.device.tvLike && box.maxWidth >= 700) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 460,
                  child: SingleChildScrollView(child: Column(children: query)),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: list),
              ],
            );
          }
          return Column(
            children: [
              ...query,
              Expanded(child: list),
            ],
          );
        },
      ),
    );
  }
}

/// The filter subwindow (UIC-SRC-02): artefact type, chapter, favorites only.
class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, required this.initial});

  final SearchFilters initial;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late SearchFilters _f = widget.initial;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final book = scope.book;
    final theme = Theme.of(context);
    final types = [
      'narrative',
      ...{for (final e in book.entities) e.group},
    ];
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.filters, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(l.filterType, style: theme.textTheme.titleSmall),
            Wrap(
              spacing: 8,
              children: [
                for (final t in types)
                  FilterChip(
                    label: Text(
                      t == 'narrative' ? l.typeNarrative : groupLabel(l, t),
                    ),
                    selected: _f.types.contains(t),
                    onSelected: (on) => setState(
                      () => _f = _f.copyWith(
                        types: on
                            ? {..._f.types, t}
                            : ({..._f.types}..remove(t)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(l.filterChapter, style: theme.textTheme.titleSmall),
            DropdownButton<String?>(
              isExpanded: true,
              value: _f.chapter,
              items: [
                DropdownMenuItem(value: null, child: Text(l.allChapters)),
                for (final c in book.chapters)
                  DropdownMenuItem(
                    value: c.id,
                    child: Text(
                      chapterTitle(book, c, scope.lang),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (v) => setState(
                () => _f = v == null
                    ? _f.copyWith(clearChapter: true)
                    : _f.copyWith(chapter: v),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.favoritesOnly),
              value: _f.favoritesOnly,
              onChanged: (v) =>
                  setState(() => _f = _f.copyWith(favoritesOnly: v)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => _f = const SearchFilters()),
                  child: Text(l.clearFilters),
                ),
                const Spacer(),
                FilledButton(
                  autofocus: true,
                  onPressed: () => Navigator.of(context).pop(_f),
                  child: Text(l.apply),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
