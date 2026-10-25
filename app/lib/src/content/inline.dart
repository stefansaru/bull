// Inline links in bundle text: `⟦artefact-id|label⟧` (bundle schema 2, UIC-LNK).

final _link = RegExp(r'⟦([^|⟧]+)\|([^⟧]*)⟧');

/// One stretch of text: plain when [target] is null, a link otherwise.
class Inline {
  const Inline(this.text, [this.target]);
  final String text;
  final String? target;
  bool get isLink => target != null;
}

List<Inline> parseInline(String text) {
  final out = <Inline>[];
  var pos = 0;
  for (final m in _link.allMatches(text)) {
    if (m.start > pos) out.add(Inline(text.substring(pos, m.start)));
    out.add(Inline(m[2]!, m[1]));
    pos = m.end;
  }
  if (pos < text.length) out.add(Inline(text.substring(pos)));
  return out;
}

/// Plain text: links reduced to their labels (search, read-aloud).
String plainLinks(String text) => text.replaceAllMapped(_link, (m) => m[2]!);

/// The targets linked from [text], in order, without repeats.
List<String> linkTargets(String text) => [
  ...{for (final m in _link.allMatches(text)) m[1]!},
];
