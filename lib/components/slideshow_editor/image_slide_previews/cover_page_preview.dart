import 'package:flutter/material.dart';

class CoverPagePreview extends StatelessWidget {
  const CoverPagePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 4,
      children: [
        Container(width: 64, height: 14, color: Colors.blueGrey[100]),
        Container(width: 32, height: 6, color: Colors.blueGrey[100]),
      ],
    );
  }
}
