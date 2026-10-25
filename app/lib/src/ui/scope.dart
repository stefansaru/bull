// Shared access to the book and settings, the layout breakpoints (APP-ADP-001), and the
// reader's navigation actions.
import 'package:flutter/widgets.dart';

import '../content/book.dart';
import '../settings.dart';

/// Width classes (Material window size classes).
enum WidthClass { compact, medium, expanded }

WidthClass widthClassOf(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w >= 840) return WidthClass.expanded;
  if (w >= 600) return WidthClass.medium;
  return WidthClass.compact;
}

/// How the shell arranges itself (UIC-LAY). Layout depends on the window, never on
/// the device type: a tablet in landscape and a TV get the same arrangement.
enum LayoutMode {
  /// Portrait: the top menu above the page, title and date line shown.
  portrait,

  /// Landscape: the menu on a left rail, title hidden behind the title button.
  rail,

  /// Wide landscape: rail, the Sections pane, and the page.
  railTwoPane,
}

/// Wide enough for the Sections pane beside a comfortable page.
const double twoPaneMinWidth = 900;

LayoutMode layoutModeOf(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  if (size.width <= size.height) return LayoutMode.portrait;
  return size.width >= twoPaneMinWidth
      ? LayoutMode.railTwoPane
      : LayoutMode.rail;
}

/// Comfortable reading measure: text never runs wider than this, whatever the screen.
const double readingWidth = 720;

class AppScope extends InheritedNotifier<Settings> {
  const AppScope({
    super.key,
    required this.book,
    required Settings settings,
    required super.child,
  }) : super(notifier: settings);

  final Book book;

  static AppScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  Settings get settings => notifier!;
  String get lang => settings.language;
}

/// What any widget may ask the reader shell to do.
abstract class ReaderActions {
  /// Open an artefact, remembering where the reader came from.
  void open(String artefactId, {String anchor = ''});

  /// Open a section as linear reading: it becomes "Continue reading" (UIC-FAV-04).
  void read(String sectionId, {bool turnPage = false});

  /// Show the preview of an artefact (prose links, UIC-LNK-02).
  Future<void> preview(String artefactId);

  void back();

  String get currentId;
}

class Reader extends InheritedWidget {
  const Reader({super.key, required this.actions, required super.child});

  final ReaderActions actions;

  static ReaderActions of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<Reader>()!.actions;

  @override
  bool updateShouldNotify(Reader old) => old.actions != actions;
}
