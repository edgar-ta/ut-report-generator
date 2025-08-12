import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ut_report_generator/utils/control_variables.dart';
import 'package:ut_report_generator/main_app.dart';

Future<Process> startPython() {
  return Process.start(LOCAL_PYTHON, [
    "-m",
    "flask",
    "--app",
    "./python-app/main.py",
    "run",
    "--port=$SERVER_PORT",
  ]);
}

void main() async {
  if (IS_DEVELOPMENT_MODE) {
    runApp(MainApp());
  } else {
    var process = await startPython();
    runApp(MainApp());
    process.kill();
  }
}
