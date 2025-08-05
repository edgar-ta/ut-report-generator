import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ut_report_generator/control_variables.dart';
import 'package:ut_report_generator/main_app.dart';

Future<Process> startPython() {
  return Process.start(
    r"D:\college\cuatrimestre-6\2025-06-16--estadias\ut-report-generator\venv\Scripts\python.exe",
    [
      "-m",
      "flask",
      "--app",
      "./python-app/main.py",
      "run",
      "--port=$SERVER_PORT",
    ],
  );
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  Future<Process> future = startPython();

  @override
  void reassemble() {
    super.reassemble();
    // This is for development only; in production, the server
    // should be started from the main function using await
    future.then((Process process) {
      print("Restarting Python server...");
      var processKilled = process.kill();
      print("Process killed: $processKilled");
    });
    future = startPython();
  }

  @override
  void dispose() {
    super.dispose();
    future.then((Process process) {
      process.kill();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainApp();
  }
}
