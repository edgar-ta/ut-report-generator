import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:ut_report_generator/api/render_report.dart';

class SuccessPreview extends StatelessWidget {
  String message;

  SuccessPreview({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 50),
        const SizedBox(height: 16),
        Text(message),
      ],
    );
  }
}
