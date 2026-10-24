// Renders one section of the book (APP-RDR-001), with its figures and tables.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../content/book.dart';
import 'image_viewer.dart';
import 'scope.dart';

class SectionView extends StatefulWidget {
  const SectionView({
    super.key,
    required this.section,
    this.onPrevious,
    this.onNext,
  });

  final Section section;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  State<SectionView> createState() => _SectionViewState();
}

class _SectionViewState extends State<SectionView> {
  final _scroll = ScrollController();

  @override
  void didUpdateWidget(SectionView old) {
    super.didUpdateWidget(old);
    if (old.section.id != widget.section.id && _scroll.hasClients) {
      _scroll.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// D-pad up/down scrolls the text on a TV remote (APP-ADP-002); when the text is
  /// at its end the key is left to focus traversal, so the user can reach the buttons.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (!_scroll.hasClients) return KeyEventResult.ignored;
    final pos = _scroll.position;
    final step = pos.viewportDimension * 0.4;
    double? target;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
        pos.pixels < pos.maxScrollExtent) {
      target = pos.pixels + step;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
        pos.pixels > pos.minScrollExtent) {
      target = pos.pixels - step;
    }
    if (target == null) return KeyEventResult.ignored;
    _scroll.animateTo(
      target.clamp(pos.minScrollExtent, pos.maxScrollExtent),
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
    );
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final lang = scope.lang;
    final theme = Theme.of(context);
    final s = widget.section;
    // Not focusable itself: key events bubble up to it from the focused button, so a
    // remote user parks on Previous/Next and the arrows scroll the text.
    final wide = widthClassOf(context) == WidthClass.expanded;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: Column(
        children: [
          if (wide)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _PrevNext(
                onPrevious: widget.onPrevious,
                onNext: widget.onNext,
              ),
            ),
          Expanded(child: _text(context, s, lang, theme)),
        ],
      ),
    );
  }

  Widget _text(BuildContext context, Section s, String lang, ThemeData theme) {
    return Scrollbar(
      controller: _scroll,
      child: ListView(
        key: PageStorageKey('section-${s.id}'),
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: readingWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      pick(s.title, lang),
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final u in s.units) _UnitView(unit: u, lang: lang),
                  const SizedBox(height: 24),
                  _PrevNext(
                    onPrevious: widget.onPrevious,
                    onNext: widget.onNext,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitView extends StatelessWidget {
  const _UnitView({required this.unit, required this.lang});

  final Unit unit;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = pick(unit.text, lang);
    final rows = unit.rowsFor(lang);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final img in unit.images)
            _Figure(asset: img, caption: pick(unit.caption, lang)),
          if (text.isNotEmpty)
            for (final para
                in text.split('\n').where((p) => p.trim().isNotEmpty))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  para,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
                ),
              ),
          if (rows.isNotEmpty) _TableView(rows: rows),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.asset, required this.caption});

  final String asset;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final path = 'assets/content/$asset';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Semantics(
            image: true,
            label: caption,
            button: true,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ImageViewer(asset: path, caption: caption),
                ),
              ),
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
              child: Text(
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

class _TableView extends StatelessWidget {
  const _TableView({required this.rows});

  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final cols = rows.fold<int>(0, (m, r) => r.length > m ? r.length : m);
    final border = Theme.of(context).dividerColor;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder.all(color: border),
        children: [
          for (final r in rows)
            TableRow(
              children: [
                for (var i = 0; i < cols; i++)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Text(i < r.length ? r[i] : ''),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PrevNext extends StatelessWidget {
  const _PrevNext({this.onPrevious, this.onNext});

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
