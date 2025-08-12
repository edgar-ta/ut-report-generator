import 'package:flutter/material.dart';

class ErrorPreview extends StatelessWidget {
  ErrorPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.error, color: Colors.red, size: 50),
        const SizedBox(height: 16),
        Text("No se pudo generar el reporte"),
      ],
    );
  }
}
