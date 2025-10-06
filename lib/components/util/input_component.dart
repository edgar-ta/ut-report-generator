import 'package:flutter/material.dart';

class InputComponent extends StatelessWidget {
  String label;
  String hint;
  TextEditingController? controller;
  void Function(String)? onChanged;

  InputComponent({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      onChanged: onChanged,
    );
  }
}
