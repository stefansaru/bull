// The reader shell (UIC-NAV-01, UIC-LAY): one artefact at a time, with the same five
// controls everywhere — back, sections, star, search, more.
//
// Portrait: the controls form the top menu; the page shows its date line and title.
// Landscape: the controls move to a left rail, in the same order, and the title moves
// behind a title button (hidden by default, to give the height to the text). Wide
// landscape adds the Sections pane beside the page.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../content/book.dart';
import '../nav/nav_stack.dart';
import 'artefact_view.dart';
import 'favorites_page.dart';
import 'menu.dart';
import 'preview.dart';
import 'scope.dart';
import 'search_page.dart';
import 'sections_panel.dart';
import 'speech_controls.dart';
import 'tour.dart';

/// Pushes a full-screen window above the shell, keeping the reader's actions in reach.
Future<T?> pushWindow<T>(
  BuildContext context,
  Widget Function() build, [
  ReaderActions? actions,
]) {
  actions ??= Reader.of(context);
  return Navigator.of(context).push<T>(
    MaterialPageRoute<T>(
      builder: (_) => Reader(actions: actions!, child: build()),
    ),
  );
}

class ReaderShell extends StatefulWidget {
  const ReaderShell({super.key, required this.initialId});

  /// Where the book opens: the last page read, else the first section.
  final String initialId;

  @override
  State<ReaderShell> createState() => _ReaderShellState();
}

class _ReaderShellState extends State<ReaderShell>
    with RestorationMixin
    implements ReaderActions {
  late final _stack = RestorableNavStack(widget.initialId);
  ScrollController? _scroll;
  String _scrollFor = '';
  bool _titleOpen = false;
  bool _paneOpen = true;
  bool _tourStarted = false;
  final tourKeys = TourKeys();

  @override
  String get restorationId => 'shell';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_stack, 'stack');
  }

  @override
  void dispose() {
    _stack.dispose();
    _scroll?.dispose();
    super.dispose();
  }

  Book get _book => AppScope.of(context).book;

  // ---------------------------------------------------------------- actions

  @override
  String get currentId => _stack.top.artefactId;

  void _remember() {
    final s = _scroll;
    if (s != null && s.hasClients) _stack.recordOffset(s.offset);
  }

  void _visit(String id) => AppScope.of(context).settings.addRecent(id);

  @override
  void open(String artefactId, {String anchor = ''}) {
    if (_book.artefact(artefactId) == null) return;
    if (artefactId == currentId && anchor.isEmpty) return;
    _remember();
    setState(() {
      _stack.push(NavEntry(artefactId, anchor: anchor));
      _titleOpen = false;
    });
    _visit(artefactId);
  }

  @override
  void read(String sectionId, {bool turnPage = false}) {
    if (_book.section(sectionId) == null) return;
    _remember();
    setState(() {
      final entry = NavEntry(sectionId);
      if (turnPage) {
        _stack.replaceTop(entry);
      } else if (sectionId != currentId) {
        _stack.push(entry);
      }
      _titleOpen = false;
    });
    AppScope.of(context).settings.setLastSection(sectionId);
    _visit(sectionId);
  }

  @override
  Future<void> preview(String artefactId) async {
    final a = _book.artefact(artefactId);
    if (a == null) return;
    if (await showPreview(context, a) && mounted) open(artefactId);
  }

  @override
  void back() {
    if (!_stack.canPop) return;
    setState(() {
      _stack.pop();
      _titleOpen = false;
    });
  }

  // ---------------------------------------------------------------- build

  ScrollController _controllerFor(NavEntry entry, int depth) {
    final key = '$depth:${entry.artefactId}';
    if (_scrollFor != key) {
      final old = _scroll;
      WidgetsBinding.instance.addPostFrameCallback((_) => old?.dispose());
      _scroll = ScrollController(initialScrollOffset: entry.offset);
      _scrollFor = key;
    }
    return _scroll!;
  }

  void _maybeStartTour() {
    if (_tourStarted || AppScope.of(context).settings.tourSeen) return;
    _tourStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) startTour(context, tourKeys, layoutModeOf(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final mode = layoutModeOf(context);
    final entry = _stack.top;
    final artefact =
        _book.artefact(entry.artefactId) ??
        _book.section(widget.initialId) ??
        _book.sections.first;
    final controller = _controllerFor(entry, _stack.value.length);
    _maybeStartTour();

    final page = NotificationListener<ScrollEndNotification>(
      onNotification: (_) {
        _remember();
        return false;
      },
      child: ArtefactView(
        key: ValueKey(_scrollFor),
        artefact: artefact,
        controller: controller,
        anchor: entry.anchor,
        showHeading: mode == LayoutMode.portrait,
      ),
    );

    final favorite = scope.settings.isFavorite(artefact.id);
    final buttons = MenuButtons(
      keys: tourKeys,
      canGoBack: _stack.canPop,
      favorite: favorite,
      onBack: back,
      onSections: () {
        if (mode == LayoutMode.railTwoPane) {
          setState(() => _paneOpen = !_paneOpen);
        } else {
          pushWindow<void>(context, () => const SectionsPage(), this);
        }
      },
      onStar: () => scope.settings.toggleFavorite(artefact.id),
      onSearch: () => pushWindow<void>(context, () => const SearchPage(), this),
      onMore: () => showMenuWindow(context, this, tourKeys, mode),
      onTitle: mode == LayoutMode.portrait
          ? null
          : () => setState(() => _titleOpen = !_titleOpen),
      titleOpen: _titleOpen,
    );

    final Widget body;
    if (mode == LayoutMode.portrait) {
      body = Column(
        children: [
          TopMenu(buttons: buttons),
          Expanded(child: page),
        ],
      );
    } else {
      final content = Stack(
        children: [
          Positioned.fill(child: page),
          if (_titleOpen)
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: TitleFlyout(
                artefact: artefact,
                onClose: () => setState(() => _titleOpen = false),
              ),
            ),
        ],
      );
      body = Row(
        children: [
          MenuRail(buttons: buttons),
          const VerticalDivider(width: 1),
          if (mode == LayoutMode.railTwoPane && _paneOpen) ...[
            SizedBox(
              width: 340,
              child: FocusTraversalGroup(
                child: SectionsPanel(currentId: artefact.id),
              ),
            ),
            const VerticalDivider(width: 1),
          ],
          Expanded(child: FocusTraversalGroup(child: content)),
        ],
      );
    }

    return Reader(
      actions: this,
      child: PopScope(
        canPop: !_stack.canPop,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) back();
        },
        child: Scaffold(
          bottomNavigationBar: const ReadAloudBar(),
          body: SafeArea(
            child: Semantics(
              label: l.appTitle,
              explicitChildNodes: true,
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}

/// The five controls, plus the landscape-only title button (UIC-NAV-01, UIC-LAY-03).
class MenuButtons {
  const MenuButtons({
    required this.keys,
    required this.canGoBack,
    required this.favorite,
    required this.onBack,
    required this.onSections,
    required this.onStar,
    required this.onSearch,
    required this.onMore,
    required this.onTitle,
    required this.titleOpen,
  });

  final TourKeys keys;
  final bool canGoBack;
  final bool favorite;
  final VoidCallback onBack, onSections, onStar, onSearch, onMore;
  final VoidCallback? onTitle;
  final bool titleOpen;

  Widget back(AppLocalizations l) => IconButton(
    key: keys.back,
    tooltip: l.back,
    onPressed: canGoBack ? onBack : null,
    icon: const Icon(Icons.arrow_back),
  );

  Widget sections(AppLocalizations l) => IconButton(
    key: keys.sections,
    tooltip: l.contents,
    onPressed: onSections,
    icon: const Icon(Icons.toc),
  );

  Widget star(AppLocalizations l) => IconButton(
    key: keys.star,
    tooltip: favorite ? l.removeFavorite : l.addFavorite,
    isSelected: favorite,
    onPressed: onStar,
    icon: const Icon(Icons.star_border),
    selectedIcon: const Icon(Icons.star),
  );

  Widget search(AppLocalizations l) => IconButton(
    key: keys.search,
    tooltip: l.search,
    onPressed: onSearch,
    icon: const Icon(Icons.search),
  );

  Widget more(AppLocalizations l) => IconButton(
    key: keys.more,
    tooltip: l.moreOptions,
    onPressed: onMore,
    icon: const Icon(Icons.more_vert),
  );

  Widget title(AppLocalizations l) => IconButton(
    key: keys.title,
    tooltip: titleOpen ? l.hideTitle : l.showTitle,
    isSelected: titleOpen,
    onPressed: onTitle,
    icon: const Icon(Icons.title),
  );
}

class TopMenu extends StatelessWidget {
  const TopMenu({super.key, required this.buttons});

  final MenuButtons buttons;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: FocusTraversalGroup(
        child: Row(
          children: [
            buttons.back(l),
            const Spacer(),
            buttons.sections(l),
            buttons.star(l),
            buttons.search(l),
            buttons.more(l),
          ],
        ),
      ),
    );
  }
}

class MenuRail extends StatelessWidget {
  const MenuRail({super.key, required this.buttons});

  final MenuButtons buttons;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: FocusTraversalGroup(
        child: SizedBox(
          width: 64,
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      buttons.back(l),
                      buttons.sections(l),
                      buttons.star(l),
                      buttons.search(l),
                      if (buttons.onTitle != null) buttons.title(l),
                      const Spacer(),
                      buttons.more(l),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Landscape: the date line and title, shown on request over the top of the page.
class TitleFlyout extends StatelessWidget {
  const TitleFlyout({super.key, required this.artefact, required this.onClose});

  final Artefact artefact;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Material(
          elevation: 6,
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(12),
          ),
          child: InkWell(
            onTap: onClose,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: ArtefactHeading(artefact: artefact),
            ),
          ),
        ),
      ),
    );
  }
}

class SectionsPage extends StatelessWidget {
  const SectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final reader = Reader.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.contents)),
      body: SectionsPanel(
        currentId: reader.currentId,
        onChosen: () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// Opens the favorites window from anywhere (Sections, the more menu).
void openFavorites(BuildContext context, [ReaderActions? actions]) =>
    pushWindow<void>(context, () => const FavoritesPage(), actions);
