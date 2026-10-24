// Reference pages: the wiki's entities (denominations, handstamps, people, places…), APP-CNT-002.
import 'package:flutter/material.dart';

import '../content/book.dart';
import 'scope.dart';

class ReferencePage extends StatelessWidget {
  const ReferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final groups = <String, List<Entity>>{};
    for (final e in scope.book.entities) {
      groups.putIfAbsent(e.group, () => []).add(e);
    }
    final names = groups.keys.toList()..sort();
    return ListView(
      key: const PageStorageKey('reference'),
      children: [
        for (final g in names)
          ExpansionTile(
            key: PageStorageKey('group-$g'),
            title: Text(_label(g)),
            children: [
              // References are subdivided by kind (books, catalogues, auctions, web…), bull DR-014.
              for (final (sub, items) in _bySubgroup(groups[g]!)) ...[
                if (sub.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Semantics(
                      header: true,
                      child: Text(
                        _label(sub),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
                for (final e in items)
                  ListTile(
                    dense: true,
                    title: Text(pick(e.title, scope.lang)),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => EntityPage(entity: e),
                      ),
                    ),
                  ),
              ],
            ],
          ),
      ],
    );
  }

  static List<(String, List<Entity>)> _bySubgroup(List<Entity> entities) {
    final subs = <String, List<Entity>>{};
    for (final e in entities) {
      subs.putIfAbsent(e.subgroup, () => []).add(e);
    }
    final keys = subs.keys.toList()..sort();
    return [for (final k in keys) (k, subs[k]!)];
  }

  static String _label(String group) => group.isEmpty
      ? group
      : group[0].toUpperCase() + group.substring(1).replaceAll('-', ' ');
}

class EntityPage extends StatelessWidget {
  const EntityPage({super.key, required this.entity});

  final Entity entity;

  @override
  Widget build(BuildContext context) {
    final lang = AppScope.of(context).lang;
    final theme = Theme.of(context);
    final lines = pick(
      entity.text,
      lang,
    ).split('\n').where((p) => p.trim().isNotEmpty);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pick(entity.title, lang),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: readingWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final line in lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: line.startsWith('#')
                          ? Semantics(
                              header: true,
                              child: Text(
                                line.replaceFirst(RegExp(r'^#+\s*'), ''),
                                style: theme.textTheme.titleMedium,
                              ),
                            )
                          : Text(
                              line,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                              ),
                            ),
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
