// The app shell: contents, reference, search, settings (APP-UX-001).
//
// Compact width: bottom navigation, the reader opens as its own page.
// Medium width: navigation rail, the reader still opens as its own page.
// Expanded width (tablet landscape, TV): navigation rail and a two-pane
// contents | reader layout (APP-ADP-001, APP-ADP-002).
//
// The selected tab and section are restorable, so a process death in the
// background returns the reader to the same place (APP-LIFE-001 / H-APP-LIFE-004).
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../content/book.dart';
import 'reader_page.dart';
import 'reference_page.dart';
import 'scope.dart';
import 'search_page.dart';
import 'section_view.dart';
import 'settings_page.dart';
import 'toc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RestorationMixin {
  final _tab = RestorableInt(0);
  final _selected = RestorableStringN(null);

  @override
  String get restorationId => 'home';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_tab, 'tab');
    registerForRestoration(_selected, 'selected');
  }

  @override
  void dispose() {
    _tab.dispose();
    _selected.dispose();
    super.dispose();
  }

  void _open(String sectionId) {
    final scope = AppScope.of(context);
    scope.settings.setLastSection(sectionId);
    setState(() {
      _selected.value = sectionId;
      _tab.value = 0;
    });
    if (widthClassOf(context) != WidthClass.expanded) {
      Navigator.of(context).restorablePush(readerRoute, arguments: sectionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final width = widthClassOf(context);
    final destinations = [
      (Icons.menu_book_outlined, Icons.menu_book, l.contents),
      (
        Icons.collections_bookmark_outlined,
        Icons.collections_bookmark,
        l.reference,
      ),
      (Icons.search, Icons.search, l.search),
      (Icons.settings_outlined, Icons.settings, l.settings),
    ];
    final body = switch (_tab.value) {
      0 => _contents(width),
      1 => const ReferencePage(),
      2 => SearchPage(onOpen: _open),
      _ => const SettingsPage(),
    };
    if (width == WidthClass.compact) {
      return Scaffold(
        appBar: AppBar(title: Text(l.appTitle)),
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab.value,
          onDestinationSelected: (i) => setState(() => _tab.value = i),
          destinations: [
            for (final d in destinations)
              NavigationDestination(
                icon: Icon(d.$1),
                selectedIcon: Icon(d.$2),
                label: d.$3,
              ),
          ],
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: _tab.value,
              onDestinationSelected: (i) => setState(() => _tab.value = i),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '1858',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.$1),
                    selectedIcon: Icon(d.$2),
                    label: Text(d.$3),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  Widget _contents(WidthClass width) {
    final toc = TableOfContents(selected: _selected.value, onOpen: _open);
    if (width != WidthClass.expanded) return toc;
    final book = AppScope.of(context).book;
    final section =
        book.section(
          _selected.value ?? AppScope.of(context).settings.lastSection ?? '',
        ) ??
        (book.sections.isEmpty ? null : book.sections.first);
    return Row(
      children: [
        SizedBox(width: 360, child: FocusTraversalGroup(child: toc)),
        const VerticalDivider(width: 1),
        Expanded(
          child: section == null
              ? const SizedBox()
              : FocusTraversalGroup(
                  child: SectionView(
                    section: section,
                    onPrevious: _neighbour(book, section, -1),
                    onNext: _neighbour(book, section, 1),
                  ),
                ),
        ),
      ],
    );
  }

  VoidCallback? _neighbour(Book book, Section s, int delta) {
    final n = book.neighbour(s.id, delta);
    return n == null ? null : () => _open(n.id);
  }
}
