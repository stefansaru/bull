// Shared access to the book and settings, plus the layout breakpoints (APP-ADP-001).
import 'package:flutter/widgets.dart';

import '../content/book.dart';
import '../settings.dart';

/// Width classes (Material window size classes). Layout depends on width, never on
/// the device type: a tablet in landscape and a TV both get the expanded layout.
enum WidthClass { compact, medium, expanded }

WidthClass widthClassOf(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w >= 840) return WidthClass.expanded;
  if (w >= 600) return WidthClass.medium;
  return WidthClass.compact;
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
