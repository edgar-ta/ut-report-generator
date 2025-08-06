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
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        fillColor: Colors.white,
        filled: true,
      ),
      onChanged: onChanged,
    );
  }
}
