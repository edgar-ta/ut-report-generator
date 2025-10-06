import 'package:flutter/material.dart';

class WelcomeText extends StatelessWidget {
  final String message;
  const WelcomeText({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(message, style: TextStyle(fontSize: 32));
  }
}
