import 'dart:io';

import 'package:ut_report_generator/utils/control_variables.dart';

Future<Process> startServer() {
  return Process.start(serverExecutable(), ["release", "${serverPort()}"]);
}
