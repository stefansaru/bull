// The in-app keyboard for TV remotes (UIC-PLT-02), ported from Day OK
// (busy/lib/widgets/keyboard.dart): on Google TV the remote's D-pad does not reach
// the system keyboard (Day OK REQ-LAY-064), so the app draws its own.
//
// One focus node for the whole grid: the arrows move the lit key, OK types it. Up
// from the top row returns to the field; Down from the bottom row moves on to the
// next control. ?123 shows the symbols, ABC the letters; both pages have the same
// shape, so the lit key keeps its place. Keys type at the end of the text.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';

const _shiftKey = '⇧', _backKey = '⌫', _doneKey = '\n';
const _symbolsKey = '?123', _lettersKey = 'ABC';

List<(String, int)> _each(String s) => [for (final k in s.characters) (k, 1)];

const _bottom = [(' ', 4), (_backKey, 2), (_doneKey, 3)];

final _pages = <List<List<(String, int)>>>[
  [
    _each('1234567890-'),
    _each('qwertyuiopă'),
    _each('asdfghjklâî'),
    [(_shiftKey, 1), ..._each('zxcvbnmșț,')],
    [(_symbolsKey, 2), ..._bottom],
  ],
  [
    _each('1234567890-'),
    _each(r'!@#$%&*()_='),
    _each('+/\\:;"\'?.,~'),
    _each('<>[]{}|^`€£'),
    [(_lettersKey, 2), ..._bottom],
  ],
];

class TvKeyboard extends StatefulWidget {
  const TvKeyboard({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.field,
    required this.doneLabel,
    required this.onDone,
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  /// The text field above, reached by Up from the top row.
  final FocusNode field;
  final String doneLabel;
  final VoidCallback onDone;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  State<TvKeyboard> createState() => TvKeyboardState();
}

class TvKeyboardState extends State<TvKeyboard> {
  int _page = 0;
  int _row = 1;
  int _col = 0;
  bool _shift = false;
  Timer? _held;

  List<List<(String, int)>> get _rows => _pages[_page];

  @visibleForTesting
  String get lit => _rows[_row][_col].$1;

  @override
  void dispose() {
    _held?.cancel();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is KeyUpEvent) return KeyEventResult.ignored;
    final key = e.logicalKey;
    if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.gameButtonA) {
      // A held OK repeats only Backspace, at a steady pace.
      if (e is KeyRepeatEvent &&
          (lit != _backKey || (_held?.isActive ?? false))) {
        return KeyEventResult.handled;
      }
      if (lit == _backKey) {
        _held?.cancel();
        _held = Timer(const Duration(milliseconds: 120), () {});
      }
      _press(lit);
      return KeyEventResult.handled;
    }
    final d = switch (key) {
      LogicalKeyboardKey.arrowUp => TraversalDirection.up,
      LogicalKeyboardKey.arrowDown => TraversalDirection.down,
      LogicalKeyboardKey.arrowLeft => TraversalDirection.left,
      LogicalKeyboardKey.arrowRight => TraversalDirection.right,
      _ => null,
    };
    if (d == null) return KeyEventResult.ignored;
    _go(d);
    return KeyEventResult.handled;
  }

  void _go(TraversalDirection d) {
    final row = _rows[_row];
    switch (d) {
      case TraversalDirection.left || TraversalDirection.right:
        final c = _col + (d == TraversalDirection.right ? 1 : -1);
        if (c >= 0 && c < row.length) setState(() => _col = c);
      case TraversalDirection.up when _row == 0:
        widget.field.requestFocus();
      case TraversalDirection.down when _row == _rows.length - 1:
        widget.focusNode.focusInDirection(d);
      case TraversalDirection.up || TraversalDirection.down:
        // The key in the next row under the middle of this one.
        int sum(List<(String, int)> r, int n) =>
            r.take(n).fold(0, (a, k) => a + k.$2);
        final x = (sum(row, _col) + row[_col].$2 / 2) / sum(row, row.length);
        final to = _row + (d == TraversalDirection.down ? 1 : -1);
        final next = _rows[to];
        final total = sum(next, next.length);
        var c = 0;
        while (c < next.length - 1 && sum(next, c + 1) / total <= x) {
          c++;
        }
        setState(() {
          _row = to;
          _col = c;
        });
    }
  }

  void _press(String k) {
    final text = widget.controller.text;
    switch (k) {
      case _doneKey:
        widget.onDone();
      case _shiftKey:
        setState(() => _shift = !_shift);
      case _symbolsKey || _lettersKey:
        setState(() => _page = k == _symbolsKey ? 1 : 0);
      case _backKey:
        if (text.isNotEmpty) _set(text.characters.skipLast(1).string);
      default:
        _set(text + (_capital ? k.toUpperCase() : k));
    }
  }

  bool get _capital => _shift && _page == 0;

  void _set(String text) {
    widget.controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    setState(() => _shift = false); // Shift lasts one letter
    widget.onChanged?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    final focused = widget.focusNode.hasFocus;
    return Focus(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: _onKey,
      onFocusChange: (_) => setState(() {}),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var r = 0; r < _rows.length; r++)
              Row(
                children: [
                  for (var i = 0; i < _rows[r].length; i++)
                    Expanded(
                      flex: _rows[r][i].$2,
                      child: _key(
                        context,
                        r,
                        i,
                        lit: focused && r == _row && i == _col,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _key(BuildContext context, int r, int i, {required bool lit}) {
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final k = _rows[r][i].$1;
    final fg = lit
        ? scheme.onPrimary
        : (k == _doneKey ? scheme.primary : scheme.onSurface);
    final shown = switch (k) {
      _doneKey => widget.doneLabel,
      ' ' => l.keyboardSpace,
      _symbolsKey || _lettersKey => k,
      _ => _capital ? k.toUpperCase() : k,
    };
    final label = switch (k) {
      _backKey => l.keyboardBackspace,
      _shiftKey => l.keyboardShift,
      _symbolsKey => l.keyboardSymbols,
      _lettersKey => l.keyboardLetters,
      _ => shown,
    };
    final face = switch (k) {
      _backKey => Icon(Icons.backspace_outlined, size: 24, color: fg),
      _shiftKey => Icon(Icons.arrow_upward, size: 24, color: fg),
      _ => Text(
        shown,
        maxLines: 1,
        overflow: TextOverflow.fade,
        softWrap: false,
        style: TextStyle(fontSize: shown.length == 1 ? 22 : 18, color: fg),
      ),
    };
    return Padding(
      padding: const EdgeInsets.all(3),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _row = r;
            _col = i;
          });
          _press(k);
        },
        child: Semantics(
          button: true,
          toggled: k == _shiftKey ? _shift : null,
          label: label,
          excludeSemantics: true,
          child: Container(
            key: ValueKey('tv-key-$k'),
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: lit
                  ? scheme.primary
                  : (k == _shiftKey && _shift
                        ? scheme.secondaryContainer
                        : scheme.surfaceContainer),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: lit ? scheme.onSurface : scheme.outlineVariant,
                width: lit ? 3 : 1,
              ),
            ),
            child: face,
          ),
        ),
      ),
    );
  }
}
