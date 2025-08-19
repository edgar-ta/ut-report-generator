import 'package:flutter/material.dart';
import 'package:ut_report_generator/utils/control_variables.dart';

class FooterComponent extends StatelessWidget {
  const FooterComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: APP_BAR_HEIGHT,
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
