import 'package:flutter/material.dart';

class FooterComponent extends StatelessWidget {
  const FooterComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Container(
        decoration: BoxDecoration(color: Color(int.parse("0xFF002855"))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Image.asset("assets/ut-footer-logos.png")],
        ),
      ),
    );
  }
}
