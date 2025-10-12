import 'package:flutter/material.dart';

class ImageLeftPreview extends StatelessWidget {
  const ImageLeftPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 96, height: 8, color: Colors.blueGrey[100]),
        SizedBox(
          width: 96,
          height: 38,
          child: Row(
            spacing: 4,
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  color: Colors.blueGrey[100],
                  child: Opacity(
                    opacity: 0.25,
                    child: Image.network(
                      "https://pixsector.com/cache/517d8be6/av5c8336583e291842624.png",
                    ),
                  ),
                ),
              ),
              Container(
                width: 54,
                height: 38,
                color: Colors.blueGrey[100],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 2,
                  children: [
                    Container(width: 46, height: 2, color: Colors.black12),
                    Container(width: 46, height: 2, color: Colors.black12),
                    Container(width: 46, height: 2, color: Colors.black12),
                    Container(width: 46, height: 2, color: Colors.black12),
                    Container(width: 46, height: 2, color: Colors.black12),
                    Container(width: 46, height: 2, color: Colors.black12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
