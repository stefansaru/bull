// A search field that works with every input (UIC-PLT-02/03).
//
// Phone and tablet: the system keyboard. TV: the field is read-only and the in-app
// keyboard sits under it, ready for the remote. A device of unknown kind keeps the
// system keyboard and adds a labelled keyboard button that opens the in-app one.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../platform.dart';
import 'scope.dart';
import 'tv_keyboard.dart';

class TvTextField extends StatefulWidget {
  const TvTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  State<TvTextField> createState() => _TvTextFieldState();
}

class _TvTextFieldState extends State<TvTextField> {
  final _field = FocusNode(debugLabel: 'search-field');
  final _keys = FocusNode(debugLabel: 'tv-keyboard');
  bool? _keyboardOpen;

  @override
  void dispose() {
    _field.dispose();
    _keys.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final device = AppScope.of(context).device;
    final tv = device == DeviceKind.tv;
    final open = _keyboardOpen ?? tv;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _field,
          autofocus: !tv,
          readOnly: tv,
          showCursor: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: widget.hint,
            border: const OutlineInputBorder(),
            suffixIcon: device == DeviceKind.other
                ? IconButton(
                    tooltip: open ? l.hideKeyboard : l.showKeyboard,
                    isSelected: open,
                    icon: const Icon(Icons.keyboard_outlined),
                    selectedIcon: const Icon(Icons.keyboard_hide_outlined),
                    onPressed: () => setState(() => _keyboardOpen = !open),
                  )
                : null,
          ),
          onChanged: widget.onChanged,
        ),
        if (open)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TvKeyboard(
              controller: widget.controller,
              focusNode: _keys,
              field: _field,
              autofocus: true,
              doneLabel: l.search,
              onDone: () => FocusScope.of(context).nextFocus(),
              onChanged: widget.onChanged,
            ),
          ),
      ],
    );
  }
}
