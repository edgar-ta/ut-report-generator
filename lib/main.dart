import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ut_report_generator/app_wrapper.dart';
import 'package:ut_report_generator/control_variables.dart';
import 'package:ut_report_generator/main_app.dart';

void main() async {
  if (IS_DEVELOPMENT_MODE) {
    runApp(AppWrapper());
  } else {
    var process = await startPython();
    runApp(MainApp());
    process.kill();
  }
}
