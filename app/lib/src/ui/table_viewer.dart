// The table viewer (UIC-TBL): one element for every table of the book.
//
// Wide tables stay upright: the first column stays in place while the rest scrolls
// sideways (bull DR-015); a full-screen mode gives the table the whole screen and
// keeps its header rows in view.
//
// Selection is keyboard-first (UIC-TBL-03): the arrows move the focused cell;
// Select on a cell starts a selection, the arrows extend it, Select ends it. Select
// on a header cell picks its column, on a first-column cell its row. Back or Escape
// clears the selection before it closes anything. On touch: tap a header for its
// row or column, tap a cell then another to select the range between them, or press
// and drag. A selection can be bookmarked (UIC-TBL-04); bookmarks store stable row
// and column ids (`<uid>-r<n>`, `<uid>-c<n>`), never screen positions.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../content/inline.dart';
import '../settings.dart';
import 'inline_text.dart';
import 'scope.dart';

/// A rectangle of cells; `allRows`/`allCols` mark a whole column or row picked.
class TableSelection {
  const TableSelection(
    this.r0,
    this.r1,
    this.c0,
    this.c1, {
    this.allRows = false,
    this.allCols = false,
  });

  final int r0, r1, c0, c1;
  final bool allRows, allCols;

  bool contains(int r, int c) =>
      (allRows || (r >= r0 && r <= r1)) && (allCols || (c >= c0 && c <= c1));

  static TableSelection span(int ra, int ca, int rb, int cb) => TableSelection(
    math.min(ra, rb),
    math.max(ra, rb),
    math.min(ca, cb),
    math.max(ca, cb),
  );

  /// Encodes the selection into stable ids for a bookmark.
  (List<String>, List<String>) ids(String uid) => (
    allRows ? const [] : [for (var r = r0; r <= r1; r++) '$uid-r$r'],
    allCols ? const [] : [for (var c = c0; c <= c1; c++) '$uid-c$c'],
  );

  /// Decodes bookmark ids; an empty list means "all".
  static TableSelection? fromIds(
    String uid,
    List<String> rows,
    List<String> cols,
  ) {
    int? idx(String id, String kind) {
      final p = '$uid-$kind';
      return id.startsWith(p) ? int.tryParse(id.substring(p.length)) : null;
    }

    final rs = [for (final r in rows) ?idx(r, 'r')];
    final cs = [for (final c in cols) ?idx(c, 'c')];
    if (rs.isEmpty && cs.isEmpty) return null;
    return TableSelection(
      rs.isEmpty ? 0 : rs.reduce(math.min),
      rs.isEmpty ? 0 : rs.reduce(math.max),
      cs.isEmpty ? 0 : cs.reduce(math.min),
      cs.isEmpty ? 0 : cs.reduce(math.max),
      allRows: rs.isEmpty,
      allCols: cs.isEmpty,
    );
  }

  /// How a bookmark anchor carries a selection: `uid|rows|cols`.
  static String anchor(String uid, List<String> rows, List<String> cols) =>
      '$uid|${rows.join(',')}|${cols.join(',')}';

  static (String, TableSelection?) parseAnchor(String anchor) {
    final parts = anchor.split('|');
    if (parts.length != 3) return (anchor, null);
    List<String> split(String s) => s.isEmpty ? const [] : s.split(',');
    return (parts[0], fromIds(parts[0], split(parts[1]), split(parts[2])));
  }
}

/// Column widths and row heights, measured once per layout so the frozen first
/// column and the scrolling part always line up.
class _Geometry {
  _Geometry(this.widths, this.heights);
  final List<double> widths;
  final List<double> heights;

  static const pad = 8.0, maxCell = 280.0, minCell = 48.0;

  static _Geometry measure(
    List<List<String>> rows,
    int cols,
    int head,
    TextStyle body,
    TextStyle header,
    TextScaler scaler,
  ) {
    TextPainter painter(String text, TextStyle style, [double? width]) =>
        TextPainter(
          text: TextSpan(text: plainLinks(text), style: style),
          textDirection: TextDirection.ltr,
          textScaler: scaler,
        )..layout(maxWidth: width ?? double.infinity);
    final widths = List<double>.filled(cols, minCell);
    for (final (r, row) in rows.indexed) {
      for (var c = 0; c < cols; c++) {
        final text = c < row.length ? row[c] : '';
        final w = painter(text, r < head ? header : body).width + 2 * pad + 1;
        widths[c] = math.max(widths[c], math.min(w, maxCell));
      }
    }
    final heights = [
      for (final (r, row) in rows.indexed)
        [
          for (var c = 0; c < cols; c++)
            painter(
                  c < row.length ? row[c] : '',
                  r < head ? header : body,
                  widths[c] - 2 * pad,
                ).height +
                2 * pad,
        ].fold<double>(minCell * 0.75, math.max),
    ];
    return _Geometry(widths, heights);
  }
}

class TableViewer extends StatefulWidget {
  const TableViewer({
    super.key,
    required this.uid,
    required this.artefactId,
    required this.rows,
    this.head = 0,
    this.initial,
    this.fullScreen = false,
  });

  final String uid;
  final String artefactId;
  final List<List<String>> rows;
  final int head;
  final TableSelection? initial;
  final bool fullScreen;

  @override
  State<TableViewer> createState() => _TableViewerState();
}

class _TableViewerState extends State<TableViewer> {
  final _focus = FocusNode(debugLabel: 'table');
  final _hBody = ScrollController();
  final _hHead = ScrollController();
  bool _syncing = false;
  late TableSelection? _selection = widget.initial;
  int _fr = 0, _fc = 0; // focused cell
  (int, int)? _anchor; // a selection being extended
  bool _tapExtends = false;
  bool _hasFocus = false;

  int get _cols =>
      widget.rows.fold<int>(0, (m, r) => r.length > m ? r.length : m);

  @override
  void initState() {
    super.initState();
    _fr = widget.head < widget.rows.length ? widget.head : 0;
    _hBody.addListener(() => _sync(_hBody, _hHead));
    _hHead.addListener(() => _sync(_hHead, _hBody));
  }

  void _sync(ScrollController from, ScrollController to) {
    if (_syncing || !to.hasClients || !from.hasClients) return;
    _syncing = true;
    to.jumpTo(from.offset.clamp(0, to.position.maxScrollExtent));
    _syncing = false;
  }

  @override
  void didUpdateWidget(TableViewer old) {
    super.didUpdateWidget(old);
    if (old.initial != widget.initial && widget.initial != null) {
      _selection = widget.initial;
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    _hBody.dispose();
    _hHead.dispose();
    super.dispose();
  }

  void _clear() => setState(() {
    _selection = null;
    _anchor = null;
    _tapExtends = false;
  });

  /// Select on a cell: header → column, first column → row, else start/end a range.
  void _activate(int r, int c) {
    setState(() {
      if (_anchor != null) {
        _anchor = null; // ends the selection being extended
      } else if (r < widget.head) {
        _selection = TableSelection(0, 0, c, c, allRows: true);
      } else if (c == 0) {
        _selection = TableSelection(r, r, 0, 0, allCols: true);
      } else {
        _anchor = (r, c);
        _selection = TableSelection(r, r, c, c);
      }
    });
  }

  void _tap(int r, int c) {
    setState(() {
      _fr = r;
      _fc = c;
      if (r < widget.head) {
        _selection = TableSelection(0, 0, c, c, allRows: true);
        _tapExtends = false;
      } else if (c == 0) {
        _selection = TableSelection(r, r, 0, 0, allCols: true);
        _tapExtends = false;
      } else if (_tapExtends && _anchor != null) {
        _selection = TableSelection.span(_anchor!.$1, _anchor!.$2, r, c);
        _anchor = null;
        _tapExtends = false;
      } else {
        _anchor = (r, c);
        _selection = TableSelection(r, r, c, c);
        _tapExtends = true;
      }
    });
    if (_anchor != null && !_tapExtends) _anchor = null;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is KeyUpEvent) return KeyEventResult.ignored;
    final key = e.logicalKey;
    if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.gameButtonA) {
      _activate(_fr, _fc);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape && _selection != null) {
      _clear();
      return KeyEventResult.handled;
    }
    final (dr, dc) = switch (key) {
      LogicalKeyboardKey.arrowUp => (-1, 0),
      LogicalKeyboardKey.arrowDown => (1, 0),
      LogicalKeyboardKey.arrowLeft => (0, -1),
      LogicalKeyboardKey.arrowRight => (0, 1),
      _ => (0, 0),
    };
    if (dr == 0 && dc == 0) return KeyEventResult.ignored;
    final r = _fr + dr, c = _fc + dc;
    // Leaving the table at its edges hands focus to the page.
    if (r < 0 || r >= widget.rows.length || c < 0 || c >= _cols) {
      return KeyEventResult.ignored;
    }
    setState(() {
      _fr = r;
      _fc = c;
      if (_anchor != null) {
        _selection = TableSelection.span(_anchor!.$1, _anchor!.$2, r, c);
      }
    });
    _revealColumn(c);
    return KeyEventResult.handled;
  }

  _Geometry? _geo;

  void _revealColumn(int c) {
    final g = _geo;
    if (g == null || c == 0 || !_hBody.hasClients) return;
    final left = g.widths.sublist(1, c).fold<double>(0, (a, w) => a + w);
    final right = left + g.widths[c];
    final pos = _hBody.position;
    if (left < pos.pixels) {
      _hBody.jumpTo(left);
    } else if (right > pos.pixels + pos.viewportDimension) {
      _hBody.jumpTo(
        (right - pos.viewportDimension).clamp(0, pos.maxScrollExtent),
      );
    }
  }

  (int, int)? _cellAt(Offset local) {
    final g = _geo;
    if (g == null) return null;
    double y = 0;
    int? r;
    for (final (i, h) in g.heights.indexed) {
      if (local.dy < y + h) {
        r = i;
        break;
      }
      y += h;
    }
    if (r == null) return null;
    if (local.dx < g.widths[0]) return (r, 0);
    var x = local.dx - g.widths[0] + (_hBody.hasClients ? _hBody.offset : 0);
    for (var c = 1; c < g.widths.length; c++) {
      if (x < g.widths[c]) return (r, c);
      x -= g.widths[c];
    }
    return null;
  }

  void _bookmark(AppLocalizations l) {
    final s = _selection;
    if (s == null) return;
    final settings = AppScope.of(context).settings;
    final (rows, cols) = s.ids(widget.uid);
    final nRows = s.allRows ? widget.rows.length : rows.length;
    final nCols = s.allCols ? _cols : cols.length;
    settings.addBookmark(
      Bookmark(
        artefactId: widget.artefactId,
        kind: BookmarkKind.table,
        anchor: widget.uid,
        rows: rows,
        cols: cols,
        label: l.tableSelection(nRows, nCols),
        created: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    ScaffoldMessenger.maybeOf(context)
        ?.showSnackBar(SnackBar(content: Text(l.selectionBookmarked)));
  }

  Future<void> _openFullScreen() {
    final actions = Reader.of(context);
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Reader(
          actions: actions,
          child: Scaffold(
            appBar: AppBar(),
            body: SafeArea(
              child: TableViewer(
                uid: widget.uid,
                artefactId: widget.artefactId,
                rows: widget.rows,
                head: widget.head,
                initial: _selection,
                fullScreen: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cell(int r, int c, _Geometry g, ThemeData theme, TextStyle style) {
    final row = widget.rows[r];
    final text = c < row.length ? row[c] : '';
    final selected = _selection?.contains(r, c) ?? false;
    final focused = _hasFocus && r == _fr && c == _fc;
    final scheme = theme.colorScheme;
    final header = r < widget.head;
    final rowHead = plainLinks(row.isEmpty ? '' : row[0]);
    final colHead = widget.head > 0 && c < widget.rows[0].length
        ? plainLinks(widget.rows[0][c])
        : '';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _tap(r, c),
      child: Semantics(
        container: true,
        selected: selected,
        label: [
          if (!header && c > 0 && rowHead.isNotEmpty) rowHead,
          if (!header && colHead.isNotEmpty) colHead,
        ].join(', '),
        child: Container(
          width: g.widths[c],
          height: g.heights[r],
          padding: const EdgeInsets.all(_Geometry.pad),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primaryContainer
                : header || c == 0
                ? scheme.surfaceContainerHigh
                : scheme.surface,
            border: Border.all(
              color: focused ? scheme.primary : theme.dividerColor,
              width: focused ? 2.5 : 0.5,
            ),
          ),
          child: InlineText(text, style: style),
        ),
      ),
    );
  }

  Widget _rows(
    Iterable<int> rows,
    _Geometry g,
    ThemeData theme,
    TextStyle body,
    TextStyle header,
    ScrollController h,
  ) {
    final rowList = rows.toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            for (final r in rowList)
              _cell(r, 0, g, theme, r < widget.head ? header : body),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final r in rowList)
                  Row(
                    children: [
                      for (var c = 1; c < _cols; c++)
                        _cell(r, c, g, theme, r < widget.head ? header : body),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final body = theme.textTheme.bodyMedium!;
    final header = body.copyWith(fontWeight: FontWeight.w600);
    if (widget.rows.isEmpty || _cols == 0) return const SizedBox.shrink();
    final g = _geo = _Geometry.measure(
      widget.rows,
      _cols,
      widget.head,
      body,
      header,
      MediaQuery.textScalerOf(context),
    );
    final toolbar = Row(
      children: [
        if (_selection != null) ...[
          Flexible(
            child: TextButton.icon(
              onPressed: () => _bookmark(l),
              icon: const Icon(Icons.bookmark_add_outlined),
              label: Text(l.bookmarkSelection, overflow: TextOverflow.ellipsis),
            ),
          ),
          IconButton(
            tooltip: l.clearSelection,
            onPressed: _clear,
            icon: const Icon(Icons.deselect),
          ),
        ],
        const Spacer(),
        if (!widget.fullScreen)
          IconButton(
            tooltip: l.fullScreenTable,
            onPressed: _openFullScreen,
            icon: const Icon(Icons.open_in_full),
          ),
      ],
    );
    final allRows = List<int>.generate(widget.rows.length, (i) => i);
    final Widget grid;
    if (widget.fullScreen) {
      grid = Column(
        children: [
          if (widget.head > 0)
            _rows(allRows.take(widget.head), g, theme, body, header, _hHead),
          Expanded(
            child: SingleChildScrollView(
              child: _rows(
                allRows.skip(widget.head),
                g,
                theme,
                body,
                header,
                _hBody,
              ),
            ),
          ),
        ],
      );
    } else {
      grid = _rows(allRows, g, theme, body, header, _hBody);
    }
    final table = Focus(
      focusNode: _focus,
      onKeyEvent: _onKey,
      onFocusChange: (f) => setState(() => _hasFocus = f),
      child: GestureDetector(
        onLongPressStart: (d) {
          final cell = _cellAt(d.localPosition);
          if (cell == null) return;
          setState(() {
            _anchor = cell;
            _selection = TableSelection(cell.$1, cell.$1, cell.$2, cell.$2);
          });
        },
        onLongPressMoveUpdate: (d) {
          final cell = _cellAt(d.localPosition);
          if (cell == null || _anchor == null) return;
          setState(
            () => _selection = TableSelection.span(
              _anchor!.$1,
              _anchor!.$2,
              cell.$1,
              cell.$2,
            ),
          );
        },
        onLongPressEnd: (_) => setState(() => _anchor = null),
        child: grid,
      ),
    );
    return PopScope(
      canPop: _selection == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _clear();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          toolbar,
          if (widget.fullScreen) Expanded(child: table) else table,
        ],
      ),
    );
  }
}
