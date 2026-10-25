// Text with links (UIC-LNK-01): a thin dotted underline marks a link — quieter than a
// hyperlink, so dense pages stay calm. Each link is a semantic link for TalkBack.
//
// Prose links open a preview first (UIC-LNK-02). On a TV remote a paragraph is
// focusable: Select previews its link, or offers a choice when it has several.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../content/book.dart';
import '../content/inline.dart';
import 'scope.dart';

TextStyle linkStyle(BuildContext context, TextStyle? base) {
  final color = Theme.of(context).colorScheme.onSurface;
  return (base ?? const TextStyle()).copyWith(
    decoration: TextDecoration.underline,
    decorationStyle: TextDecorationStyle.dotted,
    decorationThickness: 1.4,
    decorationColor: color.withValues(alpha: 0.7),
  );
}

class InlineText extends StatefulWidget {
  const InlineText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.focusable = false,
    this.autofocus = false,
    this.onLongPress,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  /// A reading paragraph: focusable for the D-pad (UIC-PLT-04).
  final bool focusable;

  /// The page's first paragraph takes focus, so a remote starts in the text.
  final bool autofocus;
  final VoidCallback? onLongPress;

  @override
  State<InlineText> createState() => _InlineTextState();
}

class _InlineTextState extends State<InlineText> {
  final _recognizers = <TapGestureRecognizer>[];
  bool _focused = false;

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  Future<void> _activate(BuildContext context) async {
    final targets = linkTargets(widget.text);
    if (targets.isEmpty) return;
    final reader = Reader.of(context);
    if (targets.length == 1) {
      await reader.preview(targets.single);
      return;
    }
    final scope = AppScope.of(context);
    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(AppLocalizations.of(ctx).linksHere),
        children: [
          for (final t in targets)
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(t),
              child: Text(
                pick(scope.book.artefact(t)?.title ?? const {}, scope.lang)
                        .isEmpty
                    ? t
                    : pick(scope.book.artefact(t)!.title, scope.lang),
              ),
            ),
        ],
      ),
    );
    if (chosen != null) await reader.preview(chosen);
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final reader = Reader.of(context);
    final style = widget.style ?? DefaultTextStyle.of(context).style;
    final spans = <InlineSpan>[
      for (final part in parseInline(widget.text))
        if (part.isLink)
          TextSpan(
            text: part.text,
            style: linkStyle(context, style),
            recognizer: (TapGestureRecognizer()
              ..onTap = () => reader.preview(part.target!))
              .also(_recognizers.add),
            semanticsLabel: part.text,
          )
        else
          TextSpan(text: part.text),
    ];
    final text = Text.rich(
      TextSpan(style: style, children: spans),
      textAlign: widget.textAlign,
    );
    if (!widget.focusable) return text;
    final scheme = Theme.of(context).colorScheme;
    final showFocus =
        _focused &&
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (f) => setState(() => _focused = f),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.gameButtonA)) {
          if (linkTargets(widget.text).isNotEmpty) {
            _activate(context);
            return KeyEventResult.handled;
          }
          if (widget.onLongPress != null) {
            widget.onLongPress!();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onLongPress: widget.onLongPress,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: showFocus ? scheme.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Padding(padding: const EdgeInsets.only(left: 6), child: text),
        ),
      ),
    );
  }
}

extension<T> on T {
  T also(void Function(T) f) {
    f(this);
    return this;
  }
}
