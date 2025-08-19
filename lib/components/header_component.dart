import 'package:flutter/material.dart';
import 'package:ut_report_generator/utils/control_variables.dart';

class HeaderComponent extends StatelessWidget {
  const HeaderComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: APP_BAR_HEIGHT,
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
