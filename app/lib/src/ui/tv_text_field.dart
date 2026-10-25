// A search field. On a TV it pairs with the in-app keyboard (UIC-PLT-02/03).
import 'package:flutter/material.dart';

class TvTextField extends StatelessWidget {
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
  Widget build(BuildContext context) => TextField(
    controller: controller,
    autofocus: true,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.search),
      hintText: hint,
      border: const OutlineInputBorder(),
    ),
    onChanged: onChanged,
  );
}
