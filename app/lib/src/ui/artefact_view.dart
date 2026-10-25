// One artefact page (UIC-ART-02): breadcrumb, date line, title, body, Related, and
// previous/next for narrative sections. Every kind of artefact uses this page; colours,
// abbreviations and indexes add their own block inside it.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../content/book.dart';
import '../content/inline.dart';
import '../settings.dart';
import '../speech/read_aloud.dart';
import 'image_viewer.dart';
import 'inline_text.dart';
import 'scope.dart';
import 'table_viewer.dart';

/// Chapter heading in the reader's language: the chapter's level-1 section, else its label.
String chapterTitle(Book book, Chapter chapter, String lang) {
  final first = book.sectionsOf(chapter).firstOrNull;
  if (first != null && first.level == 1) return pick(first.title, lang);
  return chapter.label;
}

String groupLabel(AppLocalizations l, String group) => switch (group) {
  'colors' => l.colours,
  'abbreviations' => l.abbreviations,
  _ =>
    group.isEmpty
        ? group
        : group[0].toUpperCase() + group.substring(1).replaceAll('-', ' '),
};

String relationLabel(AppLocalizations l, String rel) => switch (rel) {
  'see' => l.relSee,
  'issue' => l.relIssue,
  'denomination' => l.relDenomination,
  'handstamp' => l.relHandstamp,
  'series' => l.relSeries,
  'published in' => l.relPublishedIn,
  'in the book' => l.relInTheBook,
  'reference' => l.relReference,
  _ => l.relRelated,
};

/// The title without a leading year that the date line already shows.
String displayTitle(Artefact a, String lang) {
  final t = pick(a.title, lang);
  if (a.year.isEmpty || !t.startsWith(a.year)) return t;
  final rest = t.substring(a.year.length).trim();
  return rest.isEmpty ? t : rest;
}

/// Breadcrumb segments: (label, target id or null).
List<(String, String?)> breadcrumb(
  Book book,
  Artefact a,
  String lang,
  AppLocalizations l,
) {
  switch (a) {
    case Section s:
      final chapter = book.chapterOf(s);
      if (chapter == null) return const [];
      final first = book.sectionsOf(chapter).firstOrNull;
      return [
        (
          chapterTitle(book, chapter, lang),
          first?.id == s.id ? null : first?.id,
        ),
      ];
    case Entity e:
      final index = switch (e.group) {
        'colors' => 'index/colours',
        'abbreviations' => 'index/abbreviations',
        _ => null,
      };
      return [
        (groupLabel(l, e.group), index),
        if (e.subgroup.isNotEmpty) (groupLabel(l, e.subgroup), null),
      ];
    case BookImage _:
      return [(l.images, 'index/images')];
    case IndexInfo _:
      return [(l.indexes, null)];
  }
  return const [];
}

class ArtefactView extends StatefulWidget {
  const ArtefactView({
    super.key,
    required this.artefact,
    required this.controller,
    this.anchor = '',
    this.showHeading = true,
  });

  final Artefact artefact;
  final ScrollController controller;

  /// A unit to bring into view (a bookmark's target).
  final String anchor;

  /// False in landscape: the title and date line live behind the title button.
  final bool showHeading;

  @override
  State<ArtefactView> createState() => _ArtefactViewState();
}

class _ArtefactViewState extends State<ArtefactView> {
  final _unitKeys = <String, GlobalKey>{};

  GlobalKey _keyFor(String uid) => _unitKeys.putIfAbsent(uid, GlobalKey.new);

  @override
  void initState() {
    super.initState();
    _scheduleAnchor();
  }

  @override
  void didUpdateWidget(ArtefactView old) {
    super.didUpdateWidget(old);
    if (old.anchor != widget.anchor || old.artefact.id != widget.artefact.id) {
      _scheduleAnchor();
    }
  }

  void _scheduleAnchor() {
    if (widget.anchor.isEmpty) return;
    final (uid, _) = TableSelection.parseAnchor(widget.anchor);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _unitKeys[uid]?.currentContext;
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(ctx, alignment: 0.1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final lang = scope.lang;
    final a = widget.artefact;
    final theme = Theme.of(context);
    final reader = Reader.of(context);
    final crumbs = breadcrumb(scope.book, a, lang, l);
    return Scrollbar(
      controller: widget.controller,
      child: ListView(
        key: PageStorageKey('artefact-${a.id}'),
        controller: widget.controller,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: readingWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (crumbs.isNotEmpty) Breadcrumb(segments: crumbs),
                  if (widget.showHeading) ...[
                    const SizedBox(height: 4),
                    ArtefactHeading(artefact: a),
                  ],
                  const SizedBox(height: 16),
                  ..._body(context, a, lang, l, theme),
                  if (a.related.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    RelatedList(artefact: a),
                  ],
                  if (a case Section s) ...[
                    const SizedBox(height: 24),
                    PrevNext(
                      onPrevious: scope.book.neighbour(s.id, -1) == null
                          ? null
                          : () => reader.read(
                              scope.book.neighbour(s.id, -1)!.id,
                              turnPage: true,
                            ),
                      onNext: scope.book.neighbour(s.id, 1) == null
                          ? null
                          : () => reader.read(
                              scope.book.neighbour(s.id, 1)!.id,
                              turnPage: true,
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _body(
    BuildContext context,
    Artefact a,
    String lang,
    AppLocalizations l,
    ThemeData theme,
  ) {
    return [
      if (a case Entity e when e.type == 'color') ColourBlock(entity: e),
      if (a case Entity e when e.type == 'abbreviation')
        AbbreviationBlock(entity: e),
      if (a case IndexInfo i) IndexBody(index: i),
      if (a case BookImage img) ImageArtefactBody(image: img),
      for (final (i, u) in a.units.indexed)
        KeyedSubtree(
          key: _keyFor(u.uid),
          child: UnitView(
            unit: u,
            lang: lang,
            artefactId: a.id,
            autofocus: i == _firstReadable(a),
            selection: _selectionFor(u.uid),
          ),
        ),
    ];
  }
}

extension on _ArtefactViewState {
  /// The table selection a bookmark asks to restore, for unit [uid].
  TableSelection? _selectionFor(String uid) {
    final (anchorUid, selection) = TableSelection.parseAnchor(widget.anchor);
    return anchorUid == uid ? selection : null;
  }
}

int _firstReadable(Artefact a) => a.units.indexWhere(
  (u) => u.kind != 'heading' && u.kind != 'table' && u.text.isNotEmpty,
);

class Breadcrumb extends StatelessWidget {
  const Breadcrumb({super.key, required this.segments});

  final List<(String, String?)> segments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final reader = Reader.of(context);
    return Semantics(
      container: true,
      label: AppLocalizations.of(context).breadcrumb,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final (i, (label, target)) in segments.indexed) ...[
            if (i > 0) Text('  ›  ', style: style),
            if (target == null)
              Text(label, style: style)
            else
              InkWell(
                onTap: () => reader.open(target),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(label, style: linkStyle(context, style)),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Date line and title (UIC-ART-02/03). The date line is left out for artefacts
/// without a time (UIC-ART-04).
class ArtefactHeading extends StatelessWidget {
  const ArtefactHeading({super.key, required this.artefact});

  final Artefact artefact;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final theme = Theme.of(context);
    final a = artefact;
    final calendar = a.year.isEmpty ? null : scope.book.calendarFor(a.year);
    final yearStyle = theme.textTheme.titleSmall?.copyWith(
      color: theme.colorScheme.primary,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (a.year.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: calendar == null || calendar.id == a.id
                ? Text(a.year, style: yearStyle)
                : InkWell(
                    onTap: () => Reader.of(context).open(calendar.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        a.year,
                        style: linkStyle(context, yearStyle),
                        semanticsLabel: AppLocalizations.of(context)
                            .calendarOf(a.year),
                      ),
                    ),
                  ),
          ),
        Semantics(
          header: true,
          child: Text(
            displayTitle(a, scope.lang),
            style: theme.textTheme.headlineSmall,
          ),
        ),
      ],
    );
  }
}

class UnitView extends StatelessWidget {
  const UnitView({
    super.key,
    required this.unit,
    required this.lang,
    this.artefactId = '',
    this.autofocus = false,
    this.selection,
  });

  final Unit unit;
  final String lang;
  final String artefactId;
  final bool autofocus;

  /// A table selection to show (opened from a bookmark).
  final TableSelection? selection;

  void _bookmarkPassage(BuildContext context, String para) {
    final l = AppLocalizations.of(context);
    final settings = AppScope.of(context).settings;
    final plain = plainLinks(para);
    final b = Bookmark(
      artefactId: artefactId,
      kind: BookmarkKind.passage,
      anchor: unit.uid,
      label: plain.length > 80 ? '${plain.substring(0, 77)}…' : plain,
      created: DateTime.now().millisecondsSinceEpoch,
    );
    settings.addBookmark(b);
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(l.passageBookmarked),
        action: SnackBarAction(
          label: l.undo,
          onPressed: () => settings.removeBookmark(b),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = pick(unit.text, lang);
    final rows = unit.rowsFor(lang);
    final body = theme.textTheme.bodyLarge?.copyWith(height: 1.55);
    final paragraphs = text.split('\n').where((p) => p.trim().isNotEmpty);
    final spoken = Speech.of(context).currentUid == unit.uid;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      color: spoken
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final img in unit.images)
            Figure(file: img, caption: pick(unit.caption, lang)),
          if (unit.kind == 'heading')
            Semantics(
              header: true,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InlineText(
                  text.replaceFirst(RegExp(r'^#+\s*'), ''),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            )
          else
            for (final (i, para) in paragraphs.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InlineText(
                  unit.kind == 'list'
                      ? para.replaceFirst(RegExp(r'^\s*([-*+]|\d+\.)\s+'), '• ')
                      : para,
                  style: body,
                  focusable: true,
                  autofocus: autofocus && i == 0,
                  onBookmark: artefactId.isEmpty
                      ? null
                      : () => _bookmarkPassage(context, para),
                ),
              ),
          if (rows.isNotEmpty)
            TableViewer(
              uid: unit.uid,
              artefactId: artefactId,
              rows: rows,
              head: unit.head,
              initial: selection,
            ),
        ],
      ),
    );
  }
}

class Figure extends StatelessWidget {
  const Figure({super.key, required this.file, required this.caption});

  final String file;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final book = AppScope.of(context).book;
    final image = book.imageByFile(file);
    final path = 'assets/content/$file';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Semantics(
            image: true,
            label: caption,
            button: true,
            child: InkWell(
              onTap: () => openImageViewer(context, image, path, caption),
              child: Image.asset(
                path,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox(),
              ),
            ),
          ),
          if (caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: InlineText(
                caption,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }
}

class PrevNext extends StatelessWidget {
  const PrevNext({super.key, this.onPrevious, this.onNext});

  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        if (onPrevious != null)
          OutlinedButton.icon(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
            label: Text(l.previousSection),
          ),
        const Spacer(),
        if (onNext != null)
          FilledButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            label: Text(l.nextSection),
          ),
      ],
    );
  }
}

/// Related artefacts (UIC-ART-05): deliberate navigation, so they open directly.
class RelatedList extends StatelessWidget {
  const RelatedList({super.key, required this.artefact});

  final Artefact artefact;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final reader = Reader.of(context);
    final items = [
      for (final r in artefact.related)
        if (scope.book.artefact(r.id) != null) (r, scope.book.artefact(r.id)!),
    ];
    if (items.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            l.related,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        for (final (rel, target) in items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: target is Entity && target.hex.isNotEmpty
                ? ColourChip(hex: target.hex)
                : null,
            title: Text(pick(target.title, scope.lang)),
            subtitle: Text(relationLabel(l, rel.rel)),
            onTap: () => reader.open(target.id),
          ),
      ],
    );
  }
}

Color? colourOf(String hex) {
  final h = hex.replaceFirst('#', '');
  final v = int.tryParse(h, radix: 16);
  return h.length == 6 && v != null ? Color(0xFF000000 | v) : null;
}

/// A colour shown as itself: never recoloured by the vision modes (UIC-NAV-06).
class ColourChip extends StatelessWidget {
  const ColourChip({super.key, required this.hex, this.size = 28});

  final String hex;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: colourOf(hex),
      borderRadius: BorderRadius.circular(size / 6),
      border: Border.all(color: const Color(0xFF808080)),
    ),
  );
}

class ColourBlock extends StatelessWidget {
  const ColourBlock({super.key, required this.entity});

  final Entity entity;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A neutral frame, so the surrounding theme never tints the swatch.
        Container(
          height: 120,
          padding: const EdgeInsets.all(8),
          color: const Color(0xFF9E9E9E),
          child: Container(color: colourOf(entity.hex)),
        ),
        const SizedBox(height: 8),
        for (final s in entity.swatches)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ColourChip(hex: s.hex, size: 40),
            title: Text(
              [s.label, s.name].where((x) => x.isNotEmpty).join(' — '),
            ),
            subtitle: Text(
              [s.hex, s.description].where((x) => x.isNotEmpty).join(' · '),
            ),
          ),
        Text(
          l.swatchNote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class AbbreviationBlock extends StatelessWidget {
  const AbbreviationBlock({super.key, required this.entity});

  final Entity entity;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final reader = Reader.of(context);
    final letter = entity.abbr.isEmpty ? '' : entity.abbr[0].toUpperCase();
    final siblings = [
      for (final e in scope.book.entitiesOfType('abbreviation'))
        if (e.id != entity.id &&
            e.abbr.isNotEmpty &&
            e.abbr[0].toUpperCase() == letter)
          e,
    ];
    final see = entity.related.where((r) => r.rel == 'see').firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(entity.abbr, style: theme.textTheme.displaySmall),
        Text(
          pick(entity.expansion, scope.lang),
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        for (final lang in const ['en', 'ro', 'fr', 'de'])
          if (lang != scope.lang && entity.expansion[lang] != null)
            Text(
              '${lang.toUpperCase()}  ${entity.expansion[lang]}',
              style: theme.textTheme.bodyMedium,
            ),
        if (see != null && scope.book.artefact(see.id) != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton(
              onPressed: () => reader.open(see.id),
              child: Text(
                pick(scope.book.artefact(see.id)!.title, scope.lang),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(l.startingWith(letter), style: theme.textTheme.titleSmall),
        Wrap(
          spacing: 8,
          children: [
            for (final e in siblings)
              ActionChip(
                label: Text(e.abbr),
                tooltip: pick(e.expansion, scope.lang),
                onPressed: () => reader.open(e.id),
              ),
            if (siblings.isEmpty) const Text('—'),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => reader.open('index/abbreviations'),
            child: Text(l.allAbbreviations),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// The body of an index artefact (UIC-NAV-01a). Entries open directly.
class IndexBody extends StatelessWidget {
  const IndexBody({super.key, required this.index});

  final IndexInfo index;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final reader = Reader.of(context);
    final book = scope.book;
    final theme = Theme.of(context);
    Widget header(String text) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Semantics(
        header: true,
        child: Text(text, style: theme.textTheme.titleMedium),
      ),
    );
    switch (index.id) {
      case 'index/abbreviations':
        final all = book.entitiesOfType('abbreviation');
        final letters = <String, List<Entity>>{};
        for (final e in all) {
          letters
              .putIfAbsent(
                e.abbr.isEmpty ? '#' : e.abbr[0].toUpperCase(),
                () => [],
              )
              .add(e);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final letter in letters.keys.toList()..sort()) ...[
              header(letter),
              for (final e in letters[letter]!)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: SizedBox(width: 56, child: Text(e.abbr)),
                  title: Text(pick(e.expansion, scope.lang)),
                  onTap: () => reader.open(e.id),
                ),
            ],
          ],
        );
      case 'index/colours':
        final colours = book.entitiesOfType('color');
        final families = <String, List<Entity>>{};
        for (final e in colours) {
          families.putIfAbsent(e.family, () => []).add(e);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final f in families.keys) ...[
              header(l.colourFamily(f)),
              for (final e in families[f]!)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ColourChip(hex: e.hex),
                  title: Text(pick(e.title, scope.lang)),
                  subtitle: Text(e.swatches.map((s) => s.label).join(', ')),
                  onTap: () => reader.open(e.id),
                ),
            ],
          ],
        );
      case 'index/images':
        if (book.images.isEmpty) return Text(l.noImagesYet);
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final img in book.images)
              SizedBox(
                width: 150,
                child: InkWell(
                  onTap: () => openImageViewer(context, img, img.asset, ''),
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Image.asset(
                          img.asset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const SizedBox(),
                        ),
                      ),
                      Text(
                        '${img.number}. ${pick(img.caption, scope.lang)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final id in index.items)
              if (book.artefact(id) != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(pick(book.artefact(id)!.title, scope.lang)),
                  onTap: () => reader.open(id),
                ),
          ],
        );
    }
  }
}

class ImageArtefactBody extends StatelessWidget {
  const ImageArtefactBody({super.key, required this.image});

  final BookImage image;

  @override
  Widget build(BuildContext context) => Figure(
    file: image.file,
    caption: pick(image.caption, AppScope.of(context).lang),
  );
}
