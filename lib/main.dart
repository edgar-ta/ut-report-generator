import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ut_report_generator/main_app/main_app_wrapper.dart';
import 'package:ut_report_generator/utils/control_variables.dart';
import 'package:ut_report_generator/main_app/main_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ut_report_generator/utils/start_server.dart';

Future<void> main() async {
  await dotenv.load();

  switch (runningMode) {
    case RunningMode.development:
      ControlVariables.initialize(serverPort: 5_000);
      runApp(MainApp());
      return;

    case RunningMode.integration:
      final rootDirectory = Directory.current.path;
      ControlVariables.initialize(serverPort: 55_001);
      final pythonServer = await startServer(
        serverExecutable: "$rootDirectory\\python-app\\dist\\main.exe",
        applicationRootDirectory: rootDirectory,
      );

      runApp(MainAppWrapper(pythonServer: pythonServer));
      return;

    case RunningMode.release:
      final rootDirectory =
          File(Platform.resolvedExecutable).parent.absolute.path;
      ControlVariables.initialize(serverPort: 55_001);
      final pythonServer = await startServer(
        serverExecutable: "$rootDirectory\\main.exe",
        applicationRootDirectory: rootDirectory,
      );

      runApp(MainAppWrapper(pythonServer: pythonServer));
      return;
  }
}
