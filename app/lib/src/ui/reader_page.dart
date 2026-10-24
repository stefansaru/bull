// The reader as its own page, for compact and medium widths.
import 'package:flutter/material.dart';

import '../content/book.dart';
import 'scope.dart';
import 'section_view.dart';

/// Restorable route builder: the reader survives process death (H-APP-LIFE-004).
/// Top-level and annotated, because restoration looks it up by callback handle.
@pragma('vm:entry-point')
Route<void> readerRoute(BuildContext context, Object? arguments) =>
    MaterialPageRoute<void>(
      builder: (_) => ReaderPage(initialSection: arguments! as String),
    );

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key, required this.initialSection});

  final String initialSection;

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> with RestorationMixin {
  late final _current = RestorableString(widget.initialSection);

  @override
  String get restorationId => 'reader';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_current, 'current');
  }

  @override
  void dispose() {
    _current.dispose();
    super.dispose();
  }

  void _go(Section s) {
    AppScope.of(context).settings.setLastSection(s.id);
    setState(() => _current.value = s.id);
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final book = scope.book;
    final section = book.section(_current.value) ?? book.sections.first;
    final prev = book.neighbour(section.id, -1);
    final next = book.neighbour(section.id, 1);
    final chapter = book.chapters
        .where((c) => c.id == section.chapter)
        .firstOrNull;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          chapter?.label ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: SectionView(
          section: section,
          onPrevious: prev == null ? null : () => _go(prev),
          onNext: next == null ? null : () => _go(next),
        ),
      ),
    );
  }
}
