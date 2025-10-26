import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:ut_report_generator/utils/get_environment_variable.dart';

extension BoolParsing on bool {
  static bool parse(String value) {
    return value.toLowerCase() == "true";
  }
}

String Function() serverExecutable =
    () =>
        "${File(Platform.resolvedExecutable).parent.path}${path.separator}main.exe";
int Function() serverPort = () => isDevelopmentMode() ? 5000 : 55_001;

bool Function() isDevelopmentMode =
    () => bool.parse(getEnvironmentVariable("IS_DEVELOPMENT_MODE", "false"));
bool Function() isTestingMode =
    () => bool.parse(getEnvironmentVariable("IS_TESTING_MODE", "false"));
