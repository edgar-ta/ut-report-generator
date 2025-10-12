import 'package:flutter/material.dart';

class TitleAndContentPreview extends StatelessWidget {
  const TitleAndContentPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 96, height: 8, color: Colors.blueGrey[100]),
        Container(
          width: 96,
          height: 38,
          color: Colors.blueGrey[100],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 2,
            children: [
              Container(width: 88, height: 2, color: Colors.black12),
              Container(width: 88, height: 2, color: Colors.black12),
              Container(width: 88, height: 2, color: Colors.black12),
              Container(width: 88, height: 2, color: Colors.black12),
              Container(width: 88, height: 2, color: Colors.black12),
              Container(width: 88, height: 2, color: Colors.black12),
            ],
          ),
        ),
      ],
    );
  }
}
