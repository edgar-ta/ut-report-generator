import 'package:flutter/material.dart';

class HeaderComponent extends StatelessWidget {
  const HeaderComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Container(
        decoration: BoxDecoration(color: Color(int.parse("0xFF002855"))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset("assets/soy-ut-logo.png"),
              Image.asset("assets/ut-logos.png"),
            ],
          ),
        ),
      ),
    );
  }
}
