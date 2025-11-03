import 'package:ut_report_generator/utils/get_environment_variable.dart';

enum RunningMode { development, integration, release }

RunningMode get runningMode => RunningMode.values.byName(
  getEnvironmentVariable("RUNNING_MODE", "release"),
);

bool Function() isTestingDuringDevelopment =
    () => bool.parse(getEnvironmentVariable("IS_TESTING_MODE", "false"));

class ControlVariables {
  int serverPort;

  static ControlVariables? _instance;
  static ControlVariables get instance => _instance!;

  ControlVariables._internal({required this.serverPort});

  static ControlVariables initialize({required int serverPort}) {
    if (_instance != null) return _instance!;
    _instance = ControlVariables._internal(serverPort: serverPort);
    return _instance!;
  }
}
