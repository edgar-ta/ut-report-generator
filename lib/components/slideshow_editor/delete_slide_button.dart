import 'package:flutter/material.dart';

class DeleteSlideButton extends StatelessWidget {
  final Future<void> Function()? deleteSlide;

  const DeleteSlideButton({super.key, required this.deleteSlide});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: deleteSlide,
      label: Text("Eliminar diapositiva"),
      icon: Icon(Icons.delete),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        textStyle: TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}
