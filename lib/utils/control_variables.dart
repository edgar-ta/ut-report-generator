import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ut_report_generator/utils/get_environment_variable.dart';

extension BoolParsing on bool {
  static bool parse(String value) {
    return value.toLowerCase() == "true";
  }
}

String Function() serverExecutable =
    () => getEnvironmentVariable("SERVER_EXECUTABLE", "main.exe");
bool Function() isDevelopmentMode =
    () => bool.parse(getEnvironmentVariable("IS_DEVELOPMENT_MODE", "false"));
bool Function() isTestingMode =
    () => bool.parse(getEnvironmentVariable("IS_TESTING_MODE", "false"));
int Function() serverPort =
    () => int.parse(getEnvironmentVariable("SERVER_PORT", "55001"));
