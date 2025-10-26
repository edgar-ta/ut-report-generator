import 'dart:io';

import 'package:ut_report_generator/utils/control_variables.dart';

Future<Process> startServer() async {
  return await Process.start(
    serverExecutable(),
    ["release", "${serverPort()}"],
    mode: ProcessStartMode.normal,
    runInShell: true,
  );
}
