import 'dart:io';

import 'package:ut_report_generator/utils/control_variables.dart';

Future<Process> startServer({
  required String serverExecutable,
  required String applicationRootDirectory,
}) async {
  print("Starting the server $serverExecutable");
  final process = await Process.start(
    serverExecutable,
    [
      "release",
      ControlVariables.instance.serverPort.toString(),
      applicationRootDirectory,
    ],
    mode: ProcessStartMode.normal,
    runInShell: true,
  );
  print("Successfully started the server");
  return process;
}
