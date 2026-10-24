// Full-text search in the reader's language (APP-SRCH-001). The whole book is
// small enough to search in memory; no index is needed.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../content/book.dart';
import 'scope.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.onOpen});

  final ValueChanged<String> onOpen;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  static List<(Section, String)> search(Book book, String lang, String query) {
    final q = query.trim().toLowerCase();
    if (q.length < 2) return const [];
    final out = <(Section, String)>[];
    for (final s in book.sections) {
      final text = s.plainText(lang);
      final i = text.toLowerCase().indexOf(q);
      if (i < 0) continue;
      final start = (i - 40).clamp(0, text.length);
      final end = (i + q.length + 60).clamp(0, text.length);
      out.add((s, '…${text.substring(start, end).replaceAll('\n', ' ')}…'));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final results = search(scope.book, scope.lang, _query.text);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _query,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l.searchHint,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: results.isEmpty && _query.text.trim().length >= 2
              ? Center(child: Text(l.noResults))
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, i) {
                    final (section, snippet) = results[i];
                    return ListTile(
                      title: Text(pick(section.title, scope.lang)),
                      subtitle: Text(
                        snippet,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => widget.onOpen(section.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
